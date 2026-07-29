import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

ApplicationWindow {
    id: root
    visible: false

    property bool isFloating: false

    property real floatingX: Screen.desktopAvailableWidth * 0.2
    property real floatingY: Screen.desktopAvailableHeight * 0.3
    property real floatingWidth: 620
    property real floatingHeight: 320

    x: isFloating ? floatingX : (isOneHanded ? (oneHandedSide === "right" ? Screen.desktopAvailableWidth * 0.35 : 0) : Screen.desktopAvailableX)
    y: isFloating ? floatingY : ((Screen.desktopAvailableY + Screen.desktopAvailableHeight) - height)
    width: isFloating ? floatingWidth : (isOneHanded ? Screen.desktopAvailableWidth * 0.65 : Screen.desktopAvailableWidth)
    height: isFloating ? floatingHeight : (showNumberRow ? (isSplit ? 360 : 400) : (isSplit ? 320 : 360))
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

    function reposition() {
        if (!isFloating) {
            root.x = isOneHanded ? (oneHandedSide === "right" ? Screen.desktopAvailableWidth * 0.35 : 0) : Screen.desktopAvailableX;
            root.y = (Screen.desktopAvailableY + Screen.desktopAvailableHeight) - root.height;
            root.width = isOneHanded ? Screen.desktopAvailableWidth * 0.65 : Screen.desktopAvailableWidth;
        } else {
            root.x = floatingX;
            root.y = floatingY;
            root.width = floatingWidth;
            root.height = floatingHeight;
        }
    }

    Component.onCompleted: reposition()
    onVisibleChanged: {
        if (visible) {
            root.isShift = true;
            root.currentWord = "";
            root.lastKey = "";
            reposition();
        }
    }

    onIsFloatingChanged: {
        if (typeof inputMethod !== "undefined" && inputMethod) {
            inputMethod.setFloating(root.isFloating);
            if (root.isFloating) {
                inputMethod.setWindowPosition(root.floatingX, root.floatingY);
                inputMethod.setWindowSize(root.floatingWidth, root.floatingHeight);
            }
        }
        reposition();
    }

    function openToolsMenu() {
        suggestionBar.openToolsMenu();
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4

        // Floating Titlebar with Direct Drag Moving
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
                    text: "Plasma Virtual Keyboard (Floating - Drag Titlebar to Move)"
                    color: "#ffffff"
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    Layout.fillWidth: true
                }

                Button {
                    text: "📌 Dock to Bottom"
                    focusPolicy: Qt.NoFocus
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
                        root.floatingX += deltaX;
                        root.floatingY += deltaY;
                        if (typeof inputMethod !== "undefined" && inputMethod) {
                            inputMethod.setWindowPosition(root.floatingX, root.floatingY);
                        }
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

    // Bottom-Right Corner Resize Grip Handle for Freeform Window Scaling
    Item {
        id: resizeHandle
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: 28
        height: 28
        visible: root.isFloating
        z: 999

        Rectangle {
            anchors.fill: parent
            color: "#3daee9"
            radius: 6
            border.color: "#ffffff"
            border.width: 1
        }

        Kirigami.Icon {
            anchors.centerIn: parent
            source: "transform-scale"
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
            color: "#ffffff"
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.SizeFDiagCursor
            property point clickPos: "0,0"

            onPressed: {
                clickPos = Qt.point(mouse.x, mouse.y);
            }
            onPositionChanged: {
                if (pressed) {
                    var deltaX = mouse.x - clickPos.x;
                    var deltaY = mouse.y - clickPos.y;
                    root.floatingWidth = Math.max(380, root.floatingWidth + deltaX);
                    root.floatingHeight = Math.max(220, root.floatingHeight + deltaY);
                    if (typeof inputMethod !== "undefined" && inputMethod) {
                        inputMethod.setWindowSize(root.floatingWidth, root.floatingHeight);
                    }
                }
            }
        }
    }
}
