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
                "👃", "🧠", "🫀", "🫁", "🦷", "🦴", "👀", "👁️", "舌", "👄", "🫦", "👶", "🧒", "👦", "👧", "🧑"
            ]
        },
        {
            name: "Animals",
            icon: "applications-multimedia",
            emojis: [
                "🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐻‍❄️", "🐨", "🐯", "🦁", "🐮", "🐷", "🐽", "🐸",
                "🐵", "🙈", "🙉", "🙊", "🐒", "🐔", "🐧", "🐦", "🐤", "🐣", "🐥", "🦆", "🦅", "🦉", "🦇", "🐺",
                "🐗", "🐴", "🦄", "🐝", "🪱", "🐛", "🦋", "🐌", "🐞", "🐜", "🪰", "🪲", "🪳", "🦂", "🦟", "🦠",
                "🐢", "🐍", "蜥", "🦖", "🦕", "🐙", "🦑", "🦐", "🦞", "蟹", "🐡", "🐠", "🐟", "🐬", "🐳", "🐋",
                "🦈", "🦭", "🐊", "🐅", "🐆", "🦓", "🦍", "🦧", "🦣", "象", "🦛", "🦏", "🐪", "🐫", "🦒", "🦘"
            ]
        },
        {
            name: "Food",
            icon: "food",
            emojis: [
                "🍏", "🍎", "🍐", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓", "🫐", "🍈", "🍒", "🍑", "🥭", "🍍", "🥥",
                "🥝", "🍅", "茄", "🥑", "🥦", "🥬", "🥒", "🌶️", "🫑", "🌽", "🥕", "🫒", "🧄", "🧅", "🥔", "🍠",
                "🥐", "🥖", "🍞", "🥯", "🥨", "🧀", "蛋", "🍳", "🧈", "🥞", "🧇", "培", "🥩", "🍗", "骨", "狗",
                "汉", "薯", "披", "三", "🥙", "🧆", "塔", "卷", "沙", "煲", "面", "拉", "锅", "咖", "寿", "便",
                "饺", "蚝", "虾", "饭", "米", "饼", "竹", "团", "仙", "冰", "雪", "糕", "派", "🧁", "糕", "诞", "布",
                "棒", "糖", "巧", "爆", "圈", "饼", "栗", "花", "蜜", "奶", "茶", "壶", "绿", "酒", "香", "鸡",
                "鸡", "干", "威", "汽", "奶", "果", "马", "冰"
            ]
        },
        {
            name: "Activities",
            icon: "games-config-theme",
            emojis: [
                "⚽", "🏀", "🏈", "⚾", "🥎", "🎾", "排", "橄", "飞", "台", "溜", "乒", "羽", "冰", "曲", "曲",
                "板", "飞", "网", "高", "风", "弓", "钓", "潜", "拳", "柔", "背", "滑", "轮", "雪", "冰", "壶",
                "滑", "滑", "单", "降", "举", "摔", "体", "篮", "击", "手", "高", "骑", "瑜", "冲", "游", "水",
                "划", "攀", "山", "骑", "奖", "金", "银", "铜", "奖", "勋", "门", "票", "马", "杂", "剧", "艺",
                "电", "麦", "耳", "符", "音", "乐", "标", "保", "游", "角", "骰", "拼", "熊", "皮", "套", "牌"
            ]
        },
        {
            name: "Places",
            icon: "go-home",
            emojis: [
                "车", "出", " SUV", "巴", "邮", "救", "消", "警", "赛", "摩", "踏", "轮", "单", "滑", "警", "巡",
                "飞", "起", "降", "降", "直", "卫", "火", "飞", "帆", "快", "游", "轮", "渡", "船", "锚", "救",
                "油", "施", "红", "红", "大", "家", "房", "学", "百", "工", "城", "塔", "自", "教", "清", "印",
                "犹", "鸟", "宫", "火", "雪", "山", "营", "海", "沙", "岛", "夜", "夜", "日", "夜", "桥", "雾"
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
        spacing: 4

        // Top Toolbar: Category Selector + Backspace & Keyboard Buttons
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            spacing: 2

            // Category Tabs Repeater
            Repeater {
                model: emojiPanel.categories
                delegate: Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    flat: true
                    highlighted: emojiPanel.currentCategoryIndex === index
                    onClicked: emojiPanel.currentCategoryIndex = index

                    contentItem: RowLayout {
                        spacing: 2
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

            Rectangle {
                width: 1
                height: 24
                color: "#3e4452"
            }

            // Dedicated Backspace Delete Emoji Button
            Button {
                implicitWidth: 44
                implicitHeight: 36
                focusPolicy: Qt.NoFocus
                icon.name: "edit-clear-locationbar-rhs"
                ToolTip.visible: hovered
                ToolTip.text: "Backspace / Delete Emoji"
                onClicked: {
                    if (typeof inputMethod !== "undefined" && inputMethod) {
                        inputMethod.playClickSound();
                        inputMethod.deleteSurroundingText(2, 0);
                    }
                }
            }

            // Return to Keyboard Button
            Button {
                implicitWidth: 80
                implicitHeight: 36
                focusPolicy: Qt.NoFocus
                icon.name: "go-previous"
                text: "ABC"
                ToolTip.visible: hovered
                ToolTip.text: "Back to QWERTY Keyboard"
                onClicked: {
                    if (typeof root !== "undefined") {
                        root.activeTab = "keyboard";
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
