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
        root.activeTab = (root.activeTab === "settings" ? "keyboard" : "settings");
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

        // Quick Settings Menu Action Button (In-Place Panel Switcher)
        Button {
            id: toolsMenuBtn
            focusPolicy: Qt.NoFocus
            flat: true
            icon.name: "configure"
            text: "Tools & Modes"
            ToolTip.visible: hovered
            ToolTip.text: "Keyboard Settings & Feature Modes"
            onClicked: bar.openToolsMenu()
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
