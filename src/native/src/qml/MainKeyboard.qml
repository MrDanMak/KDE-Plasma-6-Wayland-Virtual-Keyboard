import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

ApplicationWindow {
    id: root
    visible: false
    flags: Qt.Window | Qt.WindowStaysOnTopHint | Qt.FramelessWindowHint | Qt.WindowDoesNotAcceptFocus

    x: isOneHanded ? (oneHandedSide === "right" ? Screen.desktopAvailableWidth * 0.35 : 0) : Screen.desktopAvailableX
    width: isOneHanded ? Screen.desktopAvailableWidth * 0.65 : Screen.desktopAvailableWidth
    height: showNumberRow ? (isSplit ? 340 : 360) : (isSplit ? 290 : 310)
    color: currentThemeColor

    property bool isShift: true
    property bool isCaps: false
    property bool isSymbols: false
    property bool isSplit: false
    property bool isOneHanded: false
    property bool showNumberRow: false

    property string layoutMode: "QWERTY"
    property var availableLayouts: ["QWERTY", "QWERTZ", "AZERTY", "DVORAK"]
    property int layoutIndex: 0

    property string oneHandedSide: "right"
    property int themeIndex: 0
    property var themePalettes: [
        { name: "Dark Slate",      windowBg: "#1b1e20", headerBg: "#232629", keyBg: "#2d3139", specialBg: "#1f232a", accent: "#3daee9", text: "#eff0f1" },
        { name: "Pitch Black",     windowBg: "#000000", headerBg: "#0d0d0d", keyBg: "#1a1a1a", specialBg: "#111111", accent: "#00d2ff", text: "#ffffff" },
        { name: "Midnight Navy",   windowBg: "#0f172a", headerBg: "#1e293b", keyBg: "#334155", specialBg: "#1e293b", accent: "#38bdf8", text: "#f8fafc" },
        { name: "Material Purple", windowBg: "#1e102a", headerBg: "#2a173b", keyBg: "#3d2354", specialBg: "#2a173b", accent: "#c084fc", text: "#f3e8ff" }
    ]
    property var currentPalette: themePalettes[themeIndex]
    property color currentThemeColor: currentPalette.windowBg
    property color headerColor: currentPalette.headerBg
    property color keyColor: currentPalette.keyBg
    property color specialKeyColor: currentPalette.specialBg
    property color accentColor: currentPalette.accent
    property color textColor: currentPalette.text

    property string currentWord: ""
    property string lastKey: ""
    property string activeTab: "keyboard" // "keyboard", "emoji", "clipboard", "settings"

    function updateOneHanded() {
        if (typeof inputMethod !== "undefined" && inputMethod) {
            inputMethod.setOneHanded(root.isOneHanded, root.oneHandedSide === "right");
        }
        root.x = isOneHanded ? (oneHandedSide === "right" ? Screen.desktopAvailableWidth * 0.35 : 0) : Screen.desktopAvailableX;
        root.width = isOneHanded ? Screen.desktopAvailableWidth * 0.65 : Screen.desktopAvailableWidth;
    }

    Component.onCompleted: updateOneHanded()
    onVisibleChanged: {
        if (visible) {
            root.isShift = true;
            root.currentWord = "";
            root.lastKey = "";
            updateOneHanded();
        }
    }
    onIsOneHandedChanged: updateOneHanded()
    onOneHandedSideChanged: updateOneHanded()

    function openToolsMenu() {
        root.activeTab = (root.activeTab === "settings" ? "keyboard" : "settings");
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4

        // Top GBoard Auto-Fill & Suggestion Bar
        SuggestionBar {
            id: suggestionBar
            Layout.fillWidth: true
            Layout.preferredHeight: 46
            onSuggestionClicked: function(text) {
                if (root.currentWord.length > 0) {
                    inputMethod.deleteSurroundingText(root.currentWord.length, 0);
                }
                inputMethod.commitText(text + " ");
                root.currentWord = "";
                root.lastKey = "Space";
            }
            onEmojiToggleRequested: root.activeTab = (root.activeTab === "emoji" ? "keyboard" : "emoji")
            onClipboardToggleRequested: root.activeTab = (root.activeTab === "clipboard" ? "keyboard" : "clipboard")
            onSplitToggleRequested: root.isSplit = !root.isSplit
            onNumberRowToggleRequested: root.showNumberRow = !root.showNumberRow
            onThemeToggleRequested: root.themeIndex = (root.themeIndex + 1) % root.themePalettes.length
            onOneHandedToggleRequested: {
                if (!root.isOneHanded) {
                    root.isOneHanded = true;
                    root.oneHandedSide = "right";
                } else if (root.oneHandedSide === "right") {
                    root.oneHandedSide = "left";
                } else {
                    root.isOneHanded = false;
                }
            }
            onLayoutToggleRequested: {
                root.layoutIndex = (root.layoutIndex + 1) % root.availableLayouts.length;
                root.layoutMode = root.availableLayouts[root.layoutIndex];
                if (typeof swypeEngine !== "undefined" && swypeEngine) {
                    if (root.layoutMode === "QWERTZ") swypeEngine.setLanguage("de_DE");
                    else if (root.layoutMode === "AZERTY") swypeEngine.setLanguage("fr_FR");
                    else swypeEngine.setLanguage("en_GB");
                }
            }
            onDismissRequested: inputMethod.hideKeyboard()
        }

        // Main Keyboard View Stack
        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: root.activeTab === "emoji" ? 1 : (root.activeTab === "clipboard" ? 2 : (root.activeTab === "settings" ? 3 : 0))

            // 0: Standard / Split QWERTY Grid View
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Loader {
                    anchors.fill: parent
                    source: root.isSplit ? "SplitKeyboard.qml" : "StandardKeyboard.qml"
                }
            }

            // 1: Rich Categorized Emoji Picker
            EmojiPanel {
                id: emojiPanel
                onEmojiSelected: function(emoji) {
                    inputMethod.commitText(emoji)
                }
            }

            // 2: Clipboard History Manager
            ClipboardDrawer {
                id: clipboardDrawer
                onPasteSnippet: function(text) {
                    inputMethod.commitText(text)
                    root.activeTab = "keyboard"
                }
            }

            // 3: Full In-Place Keyboard Settings View
            SettingsPanel {
                id: settingsPanel
                onCloseRequested: root.activeTab = "keyboard"
            }
        }
    }
}
