import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Item {
    id: drawer
    signal pasteSnippet(string text)

    property var pinnedItems: ["sudo pacman -Syu", "danm@cachyos-desktop"]

    property var snippets: [
        "sudo pacman -Syu",
        "danm@cachyos-desktop",
        "https://github.com/KDE/plasma-desktop",
        "Wayland zwp_input_method_v2 activated",
        "Microsoft Surface Pro Linux Kernel 6.10",
        "KWin DBus VirtualKeyboard enabled"
    ]

    function togglePin(text) {
        var idx = pinnedItems.indexOf(text);
        if (idx !== -1) {
            pinnedItems.splice(idx, 1);
        } else {
            pinnedItems.push(text);
        }
        pinnedItemsChanged();
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "Clipboard History & Pinned Snippets"
                font.pixelSize: 14
                font.bold: true
                color: "#eff0f1"
            }
            Item { Layout.fillWidth: true }
            Button {
                text: "Clear History"
                flat: true
                icon.name: "edit-clear"
                onClicked: drawer.snippets = drawer.pinnedItems.slice()
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 6
            clip: true

            model: drawer.snippets

            delegate: Rectangle {
                width: ListView.view.width
                height: 40
                color: isPinned ? "#283447" : "#2d3139"
                radius: 6
                border.color: isPinned ? ((typeof Kirigami !== "undefined" && Kirigami.Theme.highlightColor) ? Kirigami.Theme.highlightColor : "#3daee9") : "#3e4452"
                border.width: isPinned ? 1.5 : 1

                property bool isPinned: drawer.pinnedItems.indexOf(modelData) !== -1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    ToolButton {
                        icon.name: isPinned ? "bookmark-new" : "bookmark"
                        ToolTip.text: isPinned ? "Unpin Snippet" : "Pin Snippet"
                        onClicked: drawer.togglePin(modelData)
                    }

                    Text {
                        text: modelData
                        color: "#eff0f1"
                        font.pixelSize: 13
                        font.bold: isPinned
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    ToolButton {
                        icon.name: "edit-copy"
                        ToolTip.text: "Paste Snippet"
                        onClicked: drawer.pasteSnippet(modelData)
                    }
                }
            }
        }
    }
}
