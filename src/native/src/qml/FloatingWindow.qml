import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Window {
    id: floatWin
    visible: true
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    x: (Screen.desktopAvailableWidth - width) / 2
    y: (Screen.desktopAvailableHeight - height) / 2
    width: 620
    height: 320
    color: root.currentThemeColor

    onVisibleChanged: {
        if (!visible) {
            root.visible = true;
        } else {
            root.visible = false;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4

        // Floating Titlebar with Native KWin System Drag Moving
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 30
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
                    text: "Plasma Virtual Keyboard (Floating - Drag Header to Move)"
                    color: "#ffffff"
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    Layout.fillWidth: true
                }

                Button {
                    text: "📌 Dock to Bottom"
                    focusPolicy: Qt.NoFocus
                    implicitHeight: 22
                    onClicked: floatWin.visible = false
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.SizeAllCursor
                onPressed: function(mouse) {
                    if (typeof floatWin.startSystemMove === "function") {
                        floatWin.startSystemMove();
                    }
                }
            }
        }

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
            onFloatingToggleRequested: floatWin.visible = false
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

        // Main QWERTY Key Grid View
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Loader {
                anchors.fill: parent
                source: root.isSplit ? "SplitKeyboard.qml" : "StandardKeyboard.qml"
            }
        }
    }

    // Bottom-Right Corner Grip Handle for Native KWin System Resizing
    Item {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: 28
        height: 28
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
            onPressed: function(mouse) {
                if (typeof floatWin.startSystemResize === "function") {
                    floatWin.startSystemResize(Qt.RightEdge | Qt.BottomEdge);
                }
            }
        }
    }
}
