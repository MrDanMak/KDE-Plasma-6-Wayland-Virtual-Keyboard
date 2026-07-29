import QtQuick 2.15
import QtQuick.Controls 2.15
import org.kde.kirigami 2.20 as Kirigami

Item {
    id: control
    property string keyText: ""
    property string keyIcon: ""
    property bool isAccent: false
    property bool isSpecial: false

    signal clicked()

    implicitWidth: 42
    implicitHeight: 52

    scale: keyTapHandler.pressed ? 0.92 : 1.0

    Behavior on scale {
        NumberAnimation { duration: 60 }
    }

    function getAlternates(key) {
        var k = key.toUpperCase();
        if (k === "A") return ["@", "ä", "à", "á", "â"];
        if (k === "E") return ["3", "é", "è", "ê", "ë"];
        if (k === "I") return ["8", "í", "ì", "î", "ï"];
        if (k === "O") return ["9", "ó", "ò", "ô", "ö"];
        if (k === "U") return ["7", "ú", "ù", "û", "ü"];
        if (k === "C") return ["ç"];
        if (k === "N") return ["ñ"];
        if (k === "S") return ["ß"];
        if (k === "Q") return ["1"];
        if (k === "W") return ["2"];
        if (k === "R") return ["4"];
        if (k === "T") return ["5"];
        if (k === "Y") return ["6"];
        if (k === "P") return ["0"];
        return [];
    }

    property var alternatesList: getAlternates(keyText)

    Rectangle {
        id: bgRect
        anchors.fill: parent
        radius: 8
        color: {
            var activeColor = (typeof Kirigami !== "undefined" && Kirigami.Theme.highlightColor) ? Kirigami.Theme.highlightColor : "#3daee9";
            var baseColor = control.isAccent ? activeColor : (control.isSpecial ? "#272c34" : "#2d3139");
            if (typeof Kirigami !== "undefined" && Kirigami.Theme.cardBackgroundColor && Kirigami.Theme.cardBackgroundColor.a > 0) {
                if (!control.isAccent) baseColor = Kirigami.Theme.cardBackgroundColor;
            }
            return keyTapHandler.pressed ? activeColor : baseColor;
        }
        border.color: keyTapHandler.pressed ? "#ffffff" : "#3e4452"
        border.width: keyTapHandler.pressed ? 2 : 1

        Behavior on color {
            ColorAnimation { duration: 40 }
        }
    }

    Item {
        anchors.fill: parent

        Image {
            anchors.centerIn: parent
            source: control.keyIcon === "cachyos" ? "qrc:/cachyos.svg" : (control.keyIcon.startsWith("qrc:") || control.keyIcon.startsWith("file:") ? control.keyIcon : "")
            visible: source !== ""
            width: 24
            height: 24
            fillMode: Image.PreserveAspectFit
        }

        Kirigami.Icon {
            anchors.centerIn: parent
            source: (control.keyIcon !== "" && control.keyIcon !== "cachyos" && !control.keyIcon.startsWith("qrc:") && !control.keyIcon.startsWith("file:")) ? control.keyIcon : ""
            visible: source !== ""
            width: 22
            height: 22
            color: (control.isAccent || keyTapHandler.pressed) ? "#ffffff" : "#eff0f1"
        }

        Text {
            anchors.centerIn: parent
            text: control.keyText
            visible: control.keyIcon === ""
            font.pixelSize: 18
            font.weight: Font.DemiBold
            color: (control.isAccent || keyTapHandler.pressed) ? "#ffffff" : "#eff0f1"
        }

        // Small top corner hint for alternate long-press key
        Text {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 2
            anchors.rightMargin: 4
            text: control.alternatesList.length > 0 ? control.alternatesList[0] : ""
            visible: control.alternatesList.length > 0 && control.keyIcon === ""
            font.pixelSize: 10
            color: "#8a93a5"
        }
    }

    // Gboard Long-Press Popup Palette Bubble
    Popup {
        id: accentPopup
        y: -56
        x: (parent.width - width) / 2
        padding: 4
        modal: false
        focus: false
        closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape

        background: Rectangle {
            color: "#1f232a"
            radius: 12
            border.color: (typeof Kirigami !== "undefined" && Kirigami.Theme.highlightColor) ? Kirigami.Theme.highlightColor : "#3daee9"
            border.width: 1.5
        }

        contentItem: Row {
            spacing: 4
            Repeater {
                model: control.alternatesList
                Rectangle {
                    width: 34
                    height: 38
                    radius: 8
                    color: altTap.pressed ? ((typeof Kirigami !== "undefined" && Kirigami.Theme.highlightColor) ? Kirigami.Theme.highlightColor : "#3daee9") : "#2d3139"

                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        color: "#ffffff"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                    }

                    TapHandler {
                        id: altTap
                        onTapped: {
                            if (typeof inputMethod !== "undefined" && inputMethod) {
                                inputMethod.playClickSound();
                            }
                            inputMethod.commitText(modelData)
                            accentPopup.close()
                        }
                    }
                }
            }
        }
    }

    Timer {
        id: longPressTimer
        interval: 450
        repeat: false
        onTriggered: {
            if (control.keyText === "Space") return;
            if (control.alternatesList.length > 0) {
                accentPopup.open()
            }
        }
    }

    // Backspace / Key Auto-Repeat Timer
    Timer {
        id: autoRepeatDelayTimer
        interval: 350
        repeat: false
        onTriggered: {
            if (control.keyIcon === "edit-clear-locationbar-rhs") {
                autoRepeatTimer.start()
            }
        }
    }

    Timer {
        id: autoRepeatTimer
        interval: 60
        repeat: true
        onTriggered: {
            if (control.keyIcon === "edit-clear-locationbar-rhs") {
                inputMethod.deleteSurroundingText(1, 0)
            }
        }
    }

    TapHandler {
        id: keyTapHandler
        onPressedChanged: {
            if (pressed) {
                longPressTimer.start()
                if (control.keyIcon === "edit-clear-locationbar-rhs") {
                    autoRepeatDelayTimer.start()
                }
                if (typeof swypeEngine !== "undefined" && swypeEngine) {
                    var globalPos = control.mapToItem(null, control.width / 2, control.height / 2)
                    swypeEngine.updateKeyMap(control.keyText, globalPos.x, globalPos.y)
                }
            } else {
                longPressTimer.stop()
                autoRepeatDelayTimer.stop()
                autoRepeatTimer.stop()
            }
        }
        onTapped: {
            if (!accentPopup.opened) {
                if (typeof inputMethod !== "undefined" && inputMethod) {
                    inputMethod.playClickSound();
                }
                control.clicked()
            }
        }
    }
}
