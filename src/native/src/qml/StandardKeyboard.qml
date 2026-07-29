import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Item {
    id: standardLayout

    function getRow1Model() {
        if (root.isSymbols) return ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"];
        if (root.layoutMode === "QWERTZ") return ["Q", "W", "E", "R", "T", "Z", "U", "I", "O", "P"];
        if (root.layoutMode === "AZERTY") return ["A", "Z", "E", "R", "T", "Y", "U", "I", "O", "P"];
        if (root.layoutMode === "DVORAK") return [",", ".", "P", "Y", "F", "G", "C", "R", "L", "/"];
        return ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"];
    }

    function getRow2Model() {
        if (root.isSymbols) return ["@", "#", "$", "_", "&", "-", "+", "(", ")", "/"];
        if (root.layoutMode === "AZERTY") return ["Q", "S", "D", "F", "G", "H", "J", "K", "L", "M"];
        if (root.layoutMode === "DVORAK") return ["A", "O", "E", "U", "I", "D", "H", "T", "N", "S"];
        return ["A", "S", "D", "F", "G", "H", "J", "K", "L"];
    }

    function getRow3Model() {
        if (root.isSymbols) return ["*", "\"", "'", ":", ";", "!", "?", ","];
        if (root.layoutMode === "QWERTZ") return ["Y", "X", "C", "V", "B", "N", "M"];
        if (root.layoutMode === "AZERTY") return ["W", "X", "C", "V", "B", "N"];
        if (root.layoutMode === "DVORAK") return [";", "Q", "J", "K", "X", "B", "M", "W", "V", "Z"];
        return ["Z", "X", "C", "V", "B", "N", "M"];
    }

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

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 4

        // Dedicated Top Number Row
        RowLayout {
            Layout.fillWidth: true
            visible: root.showNumberRow
            spacing: 4

            Repeater {
                model: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
                KeyButton {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    keyText: modelData
                    isSpecial: true
                    onClicked: standardLayout.handleKeyPress(modelData, "")
                }
            }
        }

        // Row 1
        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            Repeater {
                model: standardLayout.getRow1Model()

                KeyButton {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    keyText: root.isSymbols ? modelData : ((root.isShift || root.isCaps) ? modelData : modelData.toLowerCase())
                    onClicked: standardLayout.handleKeyPress(modelData, "")
                }
            }
        }

        // Row 2
        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            Item { Layout.preferredWidth: 12 }

            Repeater {
                model: standardLayout.getRow2Model()

                KeyButton {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    keyText: root.isSymbols ? modelData : ((root.isShift || root.isCaps) ? modelData : modelData.toLowerCase())
                    onClicked: standardLayout.handleKeyPress(modelData, "")
                }
            }

            Item { Layout.preferredWidth: 12 }
        }

        // Row 3
        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            KeyButton {
                Layout.preferredWidth: 54
                Layout.fillHeight: true
                keyIcon: "arrow-up"
                isSpecial: true
                isAccent: root.isShift || root.isCaps
                onClicked: standardLayout.handleKeyPress("", "arrow-up")
            }

            Repeater {
                model: standardLayout.getRow3Model()

                KeyButton {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    keyText: root.isSymbols ? modelData : ((root.isShift || root.isCaps) ? modelData : modelData.toLowerCase())
                    onClicked: standardLayout.handleKeyPress(modelData, "")
                }
            }

            KeyButton {
                Layout.preferredWidth: 54
                Layout.fillHeight: true
                keyIcon: "edit-clear-locationbar-rhs"
                isSpecial: true
                onClicked: standardLayout.handleKeyPress("", "edit-clear-locationbar-rhs")
            }
        }

        // Row 4
        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            KeyButton {
                Layout.preferredWidth: 64
                Layout.fillHeight: true
                keyText: root.isSymbols ? "ABC" : "?123"
                isSpecial: true
                onClicked: standardLayout.handleKeyPress(keyText, "")
            }

            KeyButton {
                Layout.preferredWidth: 44
                Layout.fillHeight: true
                keyIcon: "cachyos"
                isSpecial: true
                ToolTip.text: "Super / Meta Key (CachyOS)"
                onClicked: standardLayout.handleKeyPress("", "cachyos")
            }

            KeyButton {
                Layout.preferredWidth: 44
                Layout.fillHeight: true
                keyIcon: "configure"
                isSpecial: true
                ToolTip.text: "Tools & Modes Menu"
                onClicked: root.openToolsMenu()
            }

            KeyButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                keyText: "Space"
                onClicked: standardLayout.handleKeyPress("Space", "")
            }

            KeyButton {
                Layout.preferredWidth: 44
                Layout.fillHeight: true
                keyText: "."
                onClicked: standardLayout.handleKeyPress(".", "")
            }

            KeyButton {
                Layout.preferredWidth: 72
                Layout.fillHeight: true
                keyIcon: "key-enter"
                isAccent: true
                onClicked: standardLayout.handleKeyPress("", "key-enter")
            }
        }
    }
}
