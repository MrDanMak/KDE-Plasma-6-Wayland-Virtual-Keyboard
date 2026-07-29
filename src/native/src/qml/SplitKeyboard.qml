import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Item {
    id: splitLayout

    function handleKeyPress(keyText, keyIcon) {
        if (keyIcon === "arrow-up") {
            if (!root.isShift && !root.isCaps) {
                root.isShift = true;
            } else if (root.isShift && !root.isCaps) {
                root.isCaps = true;
                root.isShift = false;
            } else {
                root.isShift = false;
                root.isCaps = false;
            }
            return;
        }

        if (keyIcon === "edit-clear-locationbar-rhs") {
            inputMethod.deleteSurroundingText(1, 0);
            if (root.currentWord.length > 0) {
                root.currentWord = root.currentWord.substring(0, root.currentWord.length - 1);
            }
            return;
        }

        if (keyIcon === "key-enter") {
            inputMethod.commitText("\n");
            root.currentWord = "";
            root.isShift = true;
            root.lastKey = "Enter";
            return;
        }

        if (keyIcon === "go-down-search") {
            inputMethod.hideKeyboard();
            return;
        }

        if (keyIcon === "cachyos" || keyIcon === "super" || keyText === "Super") {
            inputMethod.sendKey(133, true);
            inputMethod.sendKey(133, false);
            return;
        }

        if (keyText === "?123" || keyText === "ABC") {
            root.isSymbols = !root.isSymbols;
            return;
        }

        if (keyText === "Space") {
            if (root.lastKey === "Space") {
                inputMethod.deleteSurroundingText(1, 0);
                inputMethod.commitText(". ");
                root.isShift = true;
                root.currentWord = "";
                root.lastKey = ".";
                return;
            }

            if (root.currentWord.length >= 1 && typeof swypeEngine !== "undefined" && swypeEngine) {
                var word = root.currentWord.trim();
                var corrected = swypeEngine.getSpellingCorrection(word);
                if (corrected && corrected !== word) {
                    inputMethod.deleteSurroundingText(word.length, 0);
                    inputMethod.commitText(corrected);
                    swypeEngine.learnWord(corrected);
                } else {
                    swypeEngine.learnWord(word);
                }
            }

            inputMethod.commitText(" ");
            root.currentWord = "";
            root.lastKey = "Space";

            if (root.isShift && !root.isCaps) {
                root.isShift = false;
            }
            return;
        }

        if (keyText === "." || keyText === "?" || keyText === "!") {
            if (root.currentWord.length >= 1 && typeof swypeEngine !== "undefined" && swypeEngine) {
                var w = root.currentWord.trim();
                var corr = swypeEngine.getSpellingCorrection(w);
                if (corr && corr !== w) {
                    inputMethod.deleteSurroundingText(w.length, 0);
                    inputMethod.commitText(corr);
                }
            }
            inputMethod.commitText(keyText + " ");
            root.isShift = true;
            root.currentWord = "";
            root.lastKey = keyText;
            return;
        }

        var charToCommit = keyText;
        if (!root.isSymbols) {
            if (root.isShift || root.isCaps) {
                charToCommit = keyText.toUpperCase();
            } else {
                charToCommit = keyText.toLowerCase();
            }
        }

        inputMethod.commitText(charToCommit);
        root.currentWord += charToCommit;
        root.lastKey = charToCommit;

        if (root.isShift && !root.isCaps) {
            root.isShift = false;
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 12

        // Left Thumb Grid Block (Gboard Style)
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 6

            // Row 1 Left
            RowLayout {
                spacing: 4
                Repeater {
                    model: root.isSymbols ? ["1", "2", "3", "4", "5"] : ["Q", "W", "E", "R", "T"]
                    KeyButton {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        keyText: root.isSymbols ? modelData : ((root.isShift || root.isCaps) ? modelData : modelData.toLowerCase())
                        onClicked: splitLayout.handleKeyPress(keyText, "")
                    }
                }
            }

            // Row 2 Left
            RowLayout {
                spacing: 4
                Repeater {
                    model: root.isSymbols ? ["@", "#", "$", "_", "&"] : ["A", "S", "D", "F", "G"]
                    KeyButton {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        keyText: root.isSymbols ? modelData : ((root.isShift || root.isCaps) ? modelData : modelData.toLowerCase())
                        onClicked: splitLayout.handleKeyPress(keyText, "")
                    }
                }
            }

            // Row 3 Left
            RowLayout {
                spacing: 4
                KeyButton {
                    Layout.preferredWidth: 48
                    Layout.fillHeight: true
                    keyIcon: "arrow-up"
                    isSpecial: true
                    isAccent: root.isShift || root.isCaps
                    onClicked: splitLayout.handleKeyPress("", "arrow-up")
                }
                Repeater {
                    model: root.isSymbols ? ["*", "\"", "'", ":"] : ["Z", "X", "C", "V"]
                    KeyButton {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        keyText: root.isSymbols ? modelData : ((root.isShift || root.isCaps) ? modelData : modelData.toLowerCase())
                        onClicked: splitLayout.handleKeyPress(keyText, "")
                    }
                }
            }

            // Row 4 Left (Space + Super + Symbols)
            RowLayout {
                spacing: 4
                KeyButton {
                    Layout.preferredWidth: 54
                    Layout.fillHeight: true
                    keyText: root.isSymbols ? "ABC" : "?123"
                    isSpecial: true
                    onClicked: splitLayout.handleKeyPress(keyText, "")
                }
                KeyButton {
                    Layout.preferredWidth: 44
                    Layout.fillHeight: true
                    keyIcon: "cachyos"
                    isSpecial: true
                    onClicked: splitLayout.handleKeyPress("", "cachyos")
                }
                KeyButton {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    keyText: "Space"
                    onClicked: splitLayout.handleKeyPress("Space", "")
                }
            }
        }

        // Center Ergonomic Gap Spacer (Gboard Style)
        Item {
            Layout.preferredWidth: parent.width * 0.16
            Layout.fillHeight: true

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 6
                opacity: 0.6

                Repeater {
                    model: ["1", "2", "3", "4"]
                    Rectangle {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        radius: 16
                        color: "#272c34"
                        border.color: "#3e4452"
                        border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            color: "#8a93a5"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                        }
                    }
                }
            }
        }

        // Right Thumb Grid Block (Gboard Style)
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 6

            // Row 1 Right
            RowLayout {
                spacing: 4
                Repeater {
                    model: root.isSymbols ? ["6", "7", "8", "9", "0"] : ["Y", "U", "I", "O", "P"]
                    KeyButton {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        keyText: root.isSymbols ? modelData : ((root.isShift || root.isCaps) ? modelData : modelData.toLowerCase())
                        onClicked: splitLayout.handleKeyPress(keyText, "")
                    }
                }
            }

            // Row 2 Right
            RowLayout {
                spacing: 4
                Repeater {
                    model: root.isSymbols ? ["-", "+", "(", ")", "/"] : ["H", "J", "K", "L"]
                    KeyButton {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        keyText: root.isSymbols ? modelData : ((root.isShift || root.isCaps) ? modelData : modelData.toLowerCase())
                        onClicked: splitLayout.handleKeyPress(keyText, "")
                    }
                }
                KeyButton {
                    Layout.preferredWidth: 54
                    Layout.fillHeight: true
                    keyIcon: "edit-clear-locationbar-rhs"
                    isSpecial: true
                    onClicked: splitLayout.handleKeyPress("", "edit-clear-locationbar-rhs")
                }
            }

            // Row 3 Right
            RowLayout {
                spacing: 4
                Repeater {
                    model: root.isSymbols ? [";", "!", "?", ","] : ["B", "N", "M", "."]
                    KeyButton {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        keyText: root.isSymbols ? modelData : ((root.isShift || root.isCaps) ? modelData : modelData.toLowerCase())
                        onClicked: splitLayout.handleKeyPress(keyText, "")
                    }
                }
                KeyButton {
                    Layout.preferredWidth: 64
                    Layout.fillHeight: true
                    keyIcon: "key-enter"
                    isAccent: true
                    onClicked: splitLayout.handleKeyPress("", "key-enter")
                }
            }

            // Row 4 Right (Right Space + Hide)
            RowLayout {
                spacing: 4
                KeyButton {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    keyText: "Space"
                    onClicked: splitLayout.handleKeyPress("Space", "")
                }
                KeyButton {
                    Layout.preferredWidth: 48
                    Layout.fillHeight: true
                    keyIcon: "go-down-search"
                    isSpecial: true
                    onClicked: splitLayout.handleKeyPress("", "go-down-search")
                }
            }
        }
    }
}
