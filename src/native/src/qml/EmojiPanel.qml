import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Item {
    id: emojiPanel
    signal emojiSelected(string emoji)

    property var categories: [
        { name: "Recent", icon: "emblem-favorite", emojis: ["👍", "🔥", "❤️", "😊", "🚀", "🎉", "👏", "✨"] },
        { name: "Smileys", icon: "face-smile", emojis: ["😀", "😃", "😄", "😁", "😆", "😅", "😂", "🤣", "😊", "😇", "🙂", "🙃", "😉", "😌", "😍", "🥰", "😘", "😗", "😙", "😚", "😋", "😛", "😜", "🤪", "😝", "🤑", "🤗", "🤭", "🤫", "🤔"] },
        { name: "Animals", icon: "applications-multimedia", emojis: ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵", "🐔", "🐧", "🐦", "🐤", "🦆", "🦅", "🦉", "🦇", "🐺", "🐗"] },
        { name: "Food", icon: "food", emojis: ["🍏", "🍎", "🍐", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓", "🫐", "🍈", "🍒", "🍑", "🥭", "🍍", "🥥", "🥝", "🍅", "🍆", "🥑", "🥦", "🥬", "🥒", "🌽", "🥕", "🍕", "🍔", "🍟", "🌭", "🍿"] },
        { name: "Activities", icon: "games-config-theme", emojis: ["⚽", "🏀", "🏈", "⚾", "🥎", "🎾", "🏐", "🏉", "🥏", "🎱", "🪀", "🏓", "🏸", "🏒", "🏑", "🥍", "<ctrl42>", "🪃", "🥅", "⛳", "🪁", "🏹", "🎣", "🤿", "🥊", "🥋"] }
    ]

    property int currentCategoryIndex: 0

    ColumnLayout {
        anchors.fill: parent
        spacing: 6

        // Category Selection Tabs Bar
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            spacing: 4

            Repeater {
                model: emojiPanel.categories
                delegate: Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    flat: true
                    highlighted: emojiPanel.currentCategoryIndex === index
                    onClicked: emojiPanel.currentCategoryIndex = index

                    contentItem: RowLayout {
                        spacing: 4
                        Kirigami.Icon {
                            source: modelData.icon
                            Layout.preferredWidth: 16
                            Layout.preferredHeight: 16
                        }
                        Text {
                            text: modelData.name
                            color: "#eff0f1"
                            font.pixelSize: 12
                        }
                    }
                }
            }
        }

        // Emoji Grid View
        GridView {
            id: emojiGrid
            Layout.fillWidth: true
            Layout.fillHeight: true
            cellWidth: 48
            cellHeight: 48
            clip: true

            model: emojiPanel.categories[emojiPanel.currentCategoryIndex].emojis

            delegate: Item {
                width: 48
                height: 48

                Rectangle {
                    anchors.fill: parent
                    color: mouseArea.containsMouse ? "#3daee9" : "transparent"
                    radius: 6

                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        font.pixelSize: 26
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: emojiPanel.emojiSelected(modelData)
                    }
                }
            }
        }
    }
}
