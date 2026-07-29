import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

ApplicationWindow {
    id: root
    visible: false
    x: isFloating ? Math.max(10, Math.min(Screen.desktopAvailableWidth - width - 10, floatingX)) : (isOneHanded ? (oneHandedSide === "right" ? Screen.desktopAvailableWidth * 0.35 : 0) : Screen.desktopAvailableX)
    y: isFloating ? Math.max(10, Math.min(Screen.desktopAvailableHeight - height - 10, floatingY)) : ((Screen.desktopAvailableY + Screen.desktopAvailableHeight) - height)
    width: isFloating ? Math.min(640, Screen.desktopAvailableWidth * 0.8) : (isOneHanded ? Screen.desktopAvailableWidth * 0.65 : Screen.desktopAvailableWidth)
    height: isFloating ? 320 : (showNumberRow ? (isSplit ? 360 : 400) : (isSplit ? 320 : 360))
    color: currentThemeColor

    property bool isShift: true
    property bool isCaps: false
    property bool isSymbols: false
    property bool isSplit: false
    property bool isOneHanded: false
    property bool isFloating: false
    property bool showNumberRow: false

    property real floatingX: Screen.desktopAvailableWidth * 0.1
    property real floatingY: Screen.desktopAvailableHeight * 0.2
    property real floatingWidth: 620
    property real floatingHeight: 320

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

    function reposition() {
        if (!isFloating) {
            root.x = isOneHanded ? (oneHandedSide === "right" ? Screen.desktopAvailableWidth * 0.35 : 0) : Screen.desktopAvailableX;
            root.y = (Screen.desktopAvailableY + Screen.desktopAvailableHeight) - root.height;
            root.width = isOneHanded ? Screen.desktopAvailableWidth * 0.65 : Screen.desktopAvailableWidth;
        } else {
            root.x = Math.max(10, Math.min(Screen.desktopAvailableWidth - root.width - 10, floatingX));
            root.y = Math.max(10, Math.min(Screen.desktopAvailableHeight - root.height - 10, floatingY));
        }
    }

    Component.onCompleted: reposition()
    onVisibleChanged: {
        if (visible) {
            reposition();
            root.isShift = true;
            root.currentWord = "";
            root.lastKey = "";
        }
    }
    onHeightChanged: reposition()
    onIsOneHandedChanged: reposition()
    onIsFloatingChanged: {
        if (typeof inputMethod !== "undefined" && inputMethod) {
            inputMethod.setFloating(root.isFloating);
        }
        reposition();
    }
    onShowNumberRowChanged: reposition()

    function openToolsMenu() {
        suggestionBar.openToolsMenu();
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4

        // Floating Window Header Bar with Drag Handle
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
                    text: "Plasma Virtual Keyboard (Floating - Drag Here to Move)"
                    color: "#ffffff"
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    Layout.fillWidth: true
                }

                // Direct 1-Tap Dock Button
                Button {
                    text: "📌 Dock to Bottom"
                    focusPolicy: Qt.NoFocus
                    implicitHeight: 22
                    onClicked: root.isFloating = false
                }

                ToolButton {
                    icon.name: "window-close"
                    implicitWidth: 22
                    implicitHeight: 22
                    onClicked: root.isFloating = false
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.SizeAllCursor
                property point clickPos: "0,0"

                onPressed: {
                    clickPos = Qt.point(mouse.x, mouse.y);
                }
                onPositionChanged: {
                    if (pressed) {
                        var deltaX = mouse.x - clickPos.x;
                        var deltaY = mouse.y - clickPos.y;
                        root.floatingX = Math.max(10, Math.min(Screen.desktopAvailableWidth - root.width - 10, root.floatingX + deltaX));
                        root.floatingY = Math.max(10, Math.min(Screen.desktopAvailableHeight - root.height - 10, root.floatingY + deltaY));
                    }
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
            onFloatingToggleRequested: root.isFloating = !root.isFloating
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
