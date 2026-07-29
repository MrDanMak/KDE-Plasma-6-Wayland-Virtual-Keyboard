import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

ApplicationWindow {
    id: root
    visible: false

    property string floatPosition: "bottom" // "bottom", "left", "right", "center"
    property bool isFloating: floatPosition !== "bottom"

    x: {
        if (floatPosition === "left") return 12;
        if (floatPosition === "right") return Screen.desktopAvailableWidth - width - 12;
        if (floatPosition === "center") return (Screen.desktopAvailableWidth - width) / 2;
        return isOneHanded ? (oneHandedSide === "right" ? Screen.desktopAvailableWidth * 0.35 : 0) : Screen.desktopAvailableX;
    }

    y: {
        if (floatPosition === "center") return (Screen.desktopAvailableHeight - height) / 2;
        return (Screen.desktopAvailableY + Screen.desktopAvailableHeight) - height - (isFloating ? 12 : 0);
    }

    width: {
        if (floatPosition === "center") return Math.min(620, Screen.desktopAvailableWidth * 0.85);
        if (floatPosition === "left" || floatPosition === "right") return Math.min(580, Screen.desktopAvailableWidth * 0.55);
        return isOneHanded ? Screen.desktopAvailableWidth * 0.65 : Screen.desktopAvailableWidth;
    }

    height: showNumberRow ? (isSplit ? 360 : 400) : (isSplit ? 320 : 360)
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
    property var themeColors: ["#1b1e20", "#000000", "#1a2436", "#251738"]
    property color currentThemeColor: themeColors[themeIndex]

    property string currentWord: ""
    property string lastKey: ""
    property string activeTab: "keyboard"

    function cycleFloatPosition() {
        if (floatPosition === "bottom") floatPosition = "center";
        else if (floatPosition === "center") floatPosition = "left";
        else if (floatPosition === "left") floatPosition = "right";
        else floatPosition = "bottom";
    }

    function reposition() {
        // Automatically updates bindings for x, y, width
    }

    Component.onCompleted: reposition()
    onVisibleChanged: {
        if (visible) {
            root.isShift = true;
            root.currentWord = "";
            root.lastKey = "";
        }
    }

    function openToolsMenu() {
        suggestionBar.openToolsMenu();
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4

        // Floating Mode Titlebar with Position Selector
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            visible: root.isFloating
            color: "#272c34"
            radius: 6

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8

                Kirigami.Icon {
                    source: "transform-move"
                    Layout.preferredWidth: 16
                    Layout.preferredHeight: 16
                }

                Text {
                    text: "Plasma Virtual Keyboard (" + root.floatPosition.toUpperCase() + ")"
                    color: "#ffffff"
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    Layout.fillWidth: true
                }

                Button {
                    text: "↙️ Left"
                    focusPolicy: Qt.NoFocus
                    implicitHeight: 22
                    onClicked: root.floatPosition = "left"
                }

                Button {
                    text: "⏺ Center"
                    focusPolicy: Qt.NoFocus
                    implicitHeight: 22
                    onClicked: root.floatPosition = "center"
                }

                Button {
                    text: "↘️ Right"
                    focusPolicy: Qt.NoFocus
                    implicitHeight: 22
                    onClicked: root.floatPosition = "right"
                }

                Button {
                    text: "📌 Dock"
                    focusPolicy: Qt.NoFocus
                    implicitHeight: 22
                    onClicked: root.floatPosition = "bottom"
                }
            }
        }

        // Top GBoard Auto-Fill & Suggestion Bar
        SuggestionBar {
            id: suggestionBar
            Layout.fillWidth: true
            Layout.preferredHeight: 48
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
            onThemeToggleRequested: root.themeIndex = (root.themeIndex + 1) % root.themeColors.length
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
            onFloatingToggleRequested: root.cycleFloatPosition()
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
            currentIndex: root.activeTab === "emoji" ? 1 : (root.activeTab === "clipboard" ? 2 : 0)

            // Standard / Split QWERTY Grid View
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Loader {
                    anchors.fill: parent
                    source: root.isSplit ? "SplitKeyboard.qml" : "StandardKeyboard.qml"
                }
            }

            // Rich Categorized Emoji Picker
            EmojiPanel {
                id: emojiPanel
                onEmojiSelected: function(emoji) {
                    inputMethod.commitText(emoji)
                }
            }

            // Clipboard History Manager
            ClipboardDrawer {
                id: clipboardDrawer
                onPasteSnippet: function(text) {
                    inputMethod.commitText(text)
                    root.activeTab = "keyboard"
                }
            }
        }
    }
}
