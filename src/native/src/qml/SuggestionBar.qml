import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Rectangle {
    id: bar
    color: (typeof Kirigami !== "undefined" && Kirigami.Theme.headerBackgroundColor && Kirigami.Theme.headerBackgroundColor.a > 0) ? Kirigami.Theme.headerBackgroundColor : "#232629"
    radius: 8

    signal suggestionClicked(string text)
    signal emojiToggleRequested()
    signal clipboardToggleRequested()
    signal splitToggleRequested()
    signal themeToggleRequested()
    signal oneHandedToggleRequested()
    signal numberRowToggleRequested()
    signal floatingToggleRequested()
    signal layoutToggleRequested()
    signal dismissRequested()

    function openToolsMenu() {
        toolsMenuPopup.open();
    }

    property var candidates: {
        if (typeof swypeEngine !== "undefined" && swypeEngine && typeof inputMethod !== "undefined" && inputMethod) {
            return swypeEngine.getSuggestions(inputMethod.surroundingText);
        }
        return ["the", "colour", "favour", "behaviour"];
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 6

        // Emoji Action Button
        Button {
            focusPolicy: Qt.NoFocus
            flat: true
            icon.name: "face-smile"
            text: "Emoji"
            ToolTip.visible: hovered
            ToolTip.text: "Emoji Picker Panel"
            onClicked: bar.emojiToggleRequested()
        }

        // Clipboard Action Button
        Button {
            focusPolicy: Qt.NoFocus
            flat: true
            icon.name: "edit-paste"
            text: "Clipboard"
            ToolTip.visible: hovered
            ToolTip.text: "Clipboard History & Pinned Snippets"
            onClicked: bar.clipboardToggleRequested()
        }

        // Quick Settings Menu Action Button
        Button {
            id: toolsMenuBtn
            focusPolicy: Qt.NoFocus
            flat: true
            icon.name: "configure"
            text: "Tools & Modes"
            ToolTip.visible: hovered
            ToolTip.text: "Keyboard Settings & Feature Modes"
            onClicked: toolsMenuPopup.open()

            // Gboard Quick Settings Popup Menu
            Popup {
                id: toolsMenuPopup
                y: root.isFloating ? 30 : toolsMenuBtn.height + 4
                x: root.isFloating ? (bar.width - width) / 2 : 0
                width: 310
                padding: 10
                modal: true
                focus: false
                closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape

                background: Rectangle {
                    color: "#1f232a"
                    radius: 12
                    border.color: (typeof Kirigami !== "undefined" && Kirigami.Theme.highlightColor) ? Kirigami.Theme.highlightColor : "#3daee9"
                    border.width: 1.5
                }

                contentItem: ColumnLayout {
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 4
                        Layout.rightMargin: 4

                        Kirigami.Icon {
                            source: "configure"
                            Layout.preferredWidth: 18
                            Layout.preferredHeight: 18
                        }

                        Text {
                            text: "Keyboard Tools & Feature Modes"
                            font.pixelSize: 13
                            font.bold: true
                            color: "#ffffff"
                            Layout.fillWidth: true
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#3e4452"
                    }

                    // 1. Split Mode Option
                    Rectangle {
                        Layout.fillWidth: true
                        height: 38
                        color: splitTap.pressed ? ((typeof Kirigami !== "undefined" && Kirigami.Theme.highlightColor) ? Kirigami.Theme.highlightColor : "#3daee9") : "#2d3139"
                        radius: 8
                        border.color: "#3e4452"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10

                            Kirigami.Icon {
                                source: "view-split"
                                Layout.preferredWidth: 20
                                Layout.preferredHeight: 20
                            }

                            Text {
                                text: "Split Keyboard (Dual Thumb)"
                                color: "#eff0f1"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                Layout.fillWidth: true
                            }

                            Text {
                                text: root.isSplit ? "ON" : "OFF"
                                color: root.isSplit ? "#3daee9" : "#8a93a5"
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }

                        TapHandler {
                            id: splitTap
                            onTapped: {
                                bar.splitToggleRequested();
                                toolsMenuPopup.close();
                            }
                        }
                    }

                    // 2. Top 123 Number Row Option
                    Rectangle {
                        Layout.fillWidth: true
                        height: 38
                        color: numTap.pressed ? ((typeof Kirigami !== "undefined" && Kirigami.Theme.highlightColor) ? Kirigami.Theme.highlightColor : "#3daee9") : "#2d3139"
                        radius: 8
                        border.color: "#3e4452"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10

                            Kirigami.Icon {
                                source: "format-list-ordered"
                                Layout.preferredWidth: 20
                                Layout.preferredHeight: 20
                            }

                            Text {
                                text: "Top 123 Number Row"
                                color: "#eff0f1"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                Layout.fillWidth: true
                            }

                            Text {
                                text: root.showNumberRow ? "ON" : "OFF"
                                color: root.showNumberRow ? "#3daee9" : "#8a93a5"
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }

                        TapHandler {
                            id: numTap
                            onTapped: {
                                bar.numberRowToggleRequested();
                                toolsMenuPopup.close();
                            }
                        }
                    }

                    // 3. Layout Switcher Option
                    Rectangle {
                        Layout.fillWidth: true
                        height: 38
                        color: langTap.pressed ? ((typeof Kirigami !== "undefined" && Kirigami.Theme.highlightColor) ? Kirigami.Theme.highlightColor : "#3daee9") : "#2d3139"
                        radius: 8
                        border.color: "#3e4452"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10

                            Kirigami.Icon {
                                source: "language"
                                Layout.preferredWidth: 20
                                Layout.preferredHeight: 20
                            }

                            Text {
                                text: "Keyboard Layout"
                                color: "#eff0f1"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                Layout.fillWidth: true
                            }

                            Rectangle {
                                color: "#3daee9"
                                radius: 4
                                implicitWidth: layoutTxt.implicitWidth + 10
                                implicitHeight: 20
                                Text {
                                    id: layoutTxt
                                    anchors.centerIn: parent
                                    text: root.layoutMode ? root.layoutMode : "QWERTY"
                                    color: "#ffffff"
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                            }
                        }

                        TapHandler {
                            id: langTap
                            onTapped: {
                                bar.layoutToggleRequested();
                                toolsMenuPopup.close();
                            }
                        }
                    }

                    // 4. Gboard Theme Palette Option
                    Rectangle {
                        Layout.fillWidth: true
                        height: 38
                        color: themeTap.pressed ? ((typeof Kirigami !== "undefined" && Kirigami.Theme.highlightColor) ? Kirigami.Theme.highlightColor : "#3daee9") : "#2d3139"
                        radius: 8
                        border.color: "#3e4452"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10

                            Kirigami.Icon {
                                source: "preferences-desktop-theme"
                                Layout.preferredWidth: 20
                                Layout.preferredHeight: 20
                            }

                            Text {
                                text: "Gboard Theme Palette"
                                color: "#eff0f1"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                Layout.fillWidth: true
                            }

                            Rectangle {
                                width: 16
                                height: 16
                                radius: 8
                                color: root.currentThemeColor
                                border.color: "#ffffff"
                                border.width: 1
                            }
                        }

                        TapHandler {
                            id: themeTap
                            onTapped: {
                                bar.themeToggleRequested();
                                toolsMenuPopup.close();
                            }
                        }
                    }

                    // 5. One-Handed Mode Option
                    Rectangle {
                        Layout.fillWidth: true
                        height: 38
                        color: handTap.pressed ? ((typeof Kirigami !== "undefined" && Kirigami.Theme.highlightColor) ? Kirigami.Theme.highlightColor : "#3daee9") : "#2d3139"
                        radius: 8
                        border.color: "#3e4452"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10

                            Kirigami.Icon {
                                source: "hand"
                                Layout.preferredWidth: 20
                                Layout.preferredHeight: 20
                            }

                            Text {
                                text: "One-Handed Mode"
                                color: "#eff0f1"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                Layout.fillWidth: true
                            }

                            Text {
                                text: root.isOneHanded ? root.oneHandedSide.toUpperCase() : "OFF"
                                color: root.isOneHanded ? "#3daee9" : "#8a93a5"
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }

                        TapHandler {
                            id: handTap
                            onTapped: {
                                bar.oneHandedToggleRequested();
                                toolsMenuPopup.close();
                            }
                        }
                    }

                    // 6. Floating Window Position Option
                    Rectangle {
                        Layout.fillWidth: true
                        height: 38
                        color: floatTap.pressed ? ((typeof Kirigami !== "undefined" && Kirigami.Theme.highlightColor) ? Kirigami.Theme.highlightColor : "#3daee9") : "#2d3139"
                        radius: 8
                        border.color: "#3e4452"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10

                            Kirigami.Icon {
                                source: "window-pop-out"
                                Layout.preferredWidth: 20
                                Layout.preferredHeight: 20
                            }

                            Text {
                                text: "Floating Window Position"
                                color: "#eff0f1"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                Layout.fillWidth: true
                            }

                            Text {
                                text: root.floatPosition.toUpperCase()
                                color: root.isFloating ? "#3daee9" : "#8a93a5"
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }

                        TapHandler {
                            id: floatTap
                            onTapped: {
                                bar.floatingToggleRequested();
                                toolsMenuPopup.close();
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            width: 1
            height: 24
            color: "#3e4452"
        }

        // Suggestions Pills Carousel
        ListView {
            id: suggestionList
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: ListView.Horizontal
            spacing: 6
            clip: true

            model: bar.candidates

            delegate: Item {
                anchors.verticalCenter: parent.verticalCenter
                width: sugText.implicitWidth + 24
                height: 34

                Rectangle {
                    anchors.fill: parent
                    color: sugTap.pressed ? ((typeof Kirigami !== "undefined" && Kirigami.Theme.highlightColor) ? Kirigami.Theme.highlightColor : "#3daee9") : "#2d3139"
                    radius: 16
                    border.color: (typeof Kirigami !== "undefined" && Kirigami.Theme.highlightColor) ? Kirigami.Theme.highlightColor : "#3daee9"
                    border.width: 1
                }

                Text {
                    id: sugText
                    anchors.centerIn: parent
                    text: modelData
                    color: "#eff0f1"
                    font.pixelSize: 13
                    font.weight: Font.Medium
                }

                TapHandler {
                    id: sugTap
                    onTapped: {
                        if (typeof inputMethod !== "undefined" && inputMethod) {
                            inputMethod.playClickSound();
                        }
                        if (typeof swypeEngine !== "undefined" && swypeEngine) {
                            swypeEngine.learnWord(modelData)
                        }
                        bar.suggestionClicked(modelData)
                    }
                }
            }
        }

        // Dismiss / Hide Keyboard Action Button
        Button {
            focusPolicy: Qt.NoFocus
            flat: true
            icon.name: "go-down-search"
            text: "Hide"
            ToolTip.visible: hovered
            ToolTip.text: "Dismiss / Hide Keyboard"
            onClicked: bar.dismissRequested()
        }
    }
}
