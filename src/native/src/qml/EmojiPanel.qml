import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Item {
    id: emojiPanel
    signal emojiSelected(string emoji)

    property var categories: [
        {
            name: "Recent",
            icon: "emblem-favorite",
            emojis: ["👍", "🔥", "❤️", "😊", "🚀", "🎉", "👏", "✨", "🥰", "😍", "😂", "🤣", "😭", "🙏", "💯", "😎"]
        },
        {
            name: "Smileys",
            icon: "face-smile",
            emojis: [
                "😀", "😃", "😄", "😁", "😆", "😅", "😂", "🤣", "🥲", "🥹", "😊", "😇", "🙂", "🙃", "😉", "😌",
                "😍", "🥰", "😘", "😗", "😙", "😚", "😋", "😛", "😜", "🤪", "😝", "🤑", "🤗", "🤭", "🤫", "🤔",
                "🫡", "🤐", "🤨", "😐", "😑", "😶", "🫥", "😏", "😒", "🙄", "😬", "🤥", "🫨", "😌", "😔", "😪",
                "🤤", "😴", "😷", "🤒", "🤕", "🤢", "🤮", "🤧", "🥵", "🥶", "🥴", "😵", "🤯", "🤠", "🥳", "🥸",
                "😎", "🤓", "🧐", "😕", "😟", "🙁", "😮", "😯", "😲", "😳", "🥺", "😦", "😧", "😨", "😰", "😥",
                "😢", "😭", "😱", "😖", "😣", "😞", "😓", "😩", "😫", "🥱", "😤", "😡", "😠", "🤬", "😈", "👿",
                "💀", "☠️", "💩", "🤡", "👹", "👺", "👻", "👽", "👾", "🤖"
            ]
        },
        {
            name: "People",
            icon: "user",
            emojis: [
                "👋", "🤚", "🖐️", "✋", "🖖", "🫱", "🫲", "🫴", "🫳", "🫵", "👌", "🤌", "🤏", "✌️", "🤞", "🫰",
                "🤟", "🤘", "🤙", "👈", "👉", "👆", "🖕", "👇", "☝️", "👍", "👎", "✊", "👊", "🤛", "🤜", "👏",
                "🙌", "🫶", "👐", "🤲", "🤝", "🙏", "✍️", "💅", "🤳", "💪", "🦾", "🦿", "🦵", "🦶", "👂", "🦻",
                "👃", "🧠", "🫀", "🫁", "🦷", "🦴", "👀", "👁️", "👅", "👄", "🫦", "👶", "🧒", "👦", "👧", "🧑"
            ]
        },
        {
            name: "Animals",
            icon: "applications-multimedia",
            emojis: [
                "🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐻‍❄️", "🐨", "🐯", "🦁", "🐮", "🐷", "🐽", "🐸",
                "🐵", "🙈", "🙉", "🙊", "🐒", "🐔", "🐧", "🐦", "🐤", "🐣", "🐥", "🦆", "🦅", "🦉", "🦇", "🐺",
                "🐗", "🐴", "🦄", "🐝", "🪱", "🐛", "🦋", "🐌", "🐞", "🐜", "🪰", "🪲", "🪳", "🦂", "🦟", "🦠",
                "🐢", "🐍", "🦎", "🦖", "🦕", "🐙", "🦑", "🦐", "🦞", "🦀", "🐡", "🐠", "🐟", "🐬", "🐳", "🐋",
                "🦈", "🦭", "🐊", "🐅", "🐆", "zebra", "🦍", "🦧", "🦣", "🐘", "🦛", "🦏", "🐪", "🐫", "🦒", "🦘"
            ]
        },
        {
            name: "Food",
            icon: "food",
            emojis: [
                "🍏", "🍎", "🍐", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓", "🫐", "🍈", "🍒", "🍑", "🥭", "🍍", "🥥",
                "🥝", "🍅", "🍆", "🥑", "🥦", "🥬", "🥒", "🌶️", "🫑", "🌽", "🥕", "🫒", "🧄", "🧅", "🥔", "🍠",
                "🥐", "🥖", "🍞", "🥯", "🥨", "🧀", "🥚", "🍳", "🧈", "🥞", "🧇", "🥓", "🥩", "🍗", "🍖", "🌭",
                "🍔", "🍟", "🍕", "🥪", "🥙", "🧆", "🌮", "🌯", "🥗", "🥘", "🍝", "🍜", "🍲", "🍛", "🍣", "🍱",
                "🥟", "🦪", "🍤", "🍙", "🍚", "🍘", "🍢", "🍡", "🍧", "🍨", "🍦", "🥧", "🧁", "🍰", "🎂", "🍮",
                "🍭", "🍬", "🍫", "🍿", "🍩", "🍪", "🌰", "🥜", "🍯", "🥛", "☕", "🫖", "🍵", "🍶", "🍾", "🍷",
                "🍸", "🍹", "🍺", "🍻", "🥂", "🥃", "🥤", "🧋", "🧃", "🧉", "🧊"
            ]
        },
        {
            name: "Activities",
            icon: "games-config-theme",
            emojis: [
                "⚽", "🏀", "🏈", "⚾", "🥎", "🎾", "🏐", "🏉", "🥏", "🎱", "🪀", "🏓", "🏸", "🏒", "🏑", "🥍",
                "🏏", "🪃", "🥅", "⛳", "🪁", "🏹", "🎣", "🤿", "🥊", "🥋", "🎽", "🛹", "🛼", "🛷", "⛸️", "🥌",
                "🎿", "⛷️", "🏂", "🪂", "🏋️", "🤼", "🤸", "⛹️", "🤺", "🤾", "🏌️", "🏇", "🧘", "🏄", "🏊", "🤽",
                "🚣", "🧗", "🚵", "🚴", "🏆", "🥇", "🥈", "🥉", "🏅", "🎖️", "🎫", "🎟️", "🎪", "🤹", "🎭", "🎨",
                "🎬", "🎤", "🎧", "🎼", "🎵", "🎶", "🎯", "🎳", "🎮", "🎰", "🎲", "🧩", "🧸", "🪅", "🪆", "🃏"
            ]
        },
        {
            name: "Places",
            icon: "go-home",
            emojis: [
                "🚗", "🚕", "🚙", "🚌", "🏣", "🚑", "🚒", "🚓", "🏎️", "🏍️", "🛵", "🚲", "🛴", "🚨", "🚔", "🚘",
                "✈️", "🛫", "🛬", "🪂", "🚁", "🛰️", "🚀", "🛸", "⛵", "🚤", "🛥️", "🛳️", "⛴️", "🚢", "⚓", "🛟",
                "⛽", "🚧", "🚥", "🚦", "🏢", "🏠", "🏡", "🏫", "🏬", "🏭", "🏰", "🗼", "🗽", "⛪", "🕌", "🛕",
                "🕍", "⛩️", "🏛️", "🌋", "🏔️", "⛰️", "🏕️", "🏖️", "🏜️", "🏝️", "🏙️", "🌆", "🌇", "🌃", "🌉", "🌁"
            ]
        },
        {
            name: "Symbols",
            icon: "emblem-symbolic-link",
            emojis: [
                "💡", "🔦", "🏮", "🕯️", "🪔", "📦", "🏷️", "✉️", "📧", "📩", "📨", "📜", "📄", "📑", "🧾", "📊",
                "📈", "📉", "🗒️", "🗓️", "📅", "🗑️", "📇", "📋", "📁", "📂", "🗞️", "📰", "📓", "📕", "📗", "📘",
                "📙", "📔", "📒", "📚", "📖", "🔖", "🧷", "🔗", "📎", "📌", "📍", "✂️", "🖊️", "🖋️", "✒️", "🖌️",
                "🖍️", "📝", "✏️", "🔍", "🔎", "🔏", "🔐", "🔒", "🔓", "❤️", "🧡", "💛", "💚", "💙", "💜", "🖤",
                "🤍", "🤎", "💔", "❣️", "💕", "💞", "💓", "💗", "💖", "💘", "💝", "💯", "💢", "💬", "💭", "💤",
                "🌐", "♨️", "🛑", "🕛", "🕒", "🕕", "🕘", "❓", "❗", "🚫", "⛔", "📛", "⚠️", "♻️", "✅", "❎"
            ]
        }
    ]

    property int currentCategoryIndex: 0

    ColumnLayout {
        anchors.fill: parent
        spacing: 6

        // Category Selection Tabs Bar
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            spacing: 2

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
                            color: (typeof root !== "undefined" && root.textColor) ? root.textColor : "#eff0f1"
                            font.pixelSize: 11
                            font.bold: emojiPanel.currentCategoryIndex === index
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#3e4452"
        }

        // Emoji Grid View
        GridView {
            id: emojiGrid
            Layout.fillWidth: true
            Layout.fillHeight: true
            cellWidth: 46
            cellHeight: 46
            clip: true

            model: emojiPanel.categories[emojiPanel.currentCategoryIndex].emojis

            delegate: Item {
                width: 46
                height: 46

                Rectangle {
                    anchors.fill: parent
                    color: mouseArea.pressed ? ((typeof root !== "undefined" && root.accentColor) ? root.accentColor : "#3daee9") : (mouseArea.containsMouse ? "#2d3848" : "transparent")
                    radius: 8

                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        font.pixelSize: 24
                    }

                    TapHandler {
                        id: mouseArea
                        onTapped: {
                            if (typeof inputMethod !== "undefined" && inputMethod) {
                                inputMethod.playClickSound();
                            }
                            emojiPanel.emojiSelected(modelData);
                        }
                    }
                }
            }
        }
    }
}
