import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Rectangle {
    id: settingsPanel
    color: "#181a1d"
    radius: 8

    signal closeRequested()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        // Settings Header Bar
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Kirigami.Icon {
                source: "configure"
                Layout.preferredWidth: 22
                Layout.preferredHeight: 22
            }

            Text {
                text: "Keyboard Settings & Feature Modes"
                color: "#ffffff"
                font.pixelSize: 15
                font.bold: true
                Layout.fillWidth: true
            }

            Button {
                text: "⬅ Back to Keyboard"
                icon.name: "go-previous"
                focusPolicy: Qt.NoFocus
                onClicked: settingsPanel.closeRequested()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#3e4452"
        }

        // Settings Grid Tiles
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 3
            columnSpacing: 8
            rowSpacing: 8

            // 1. Split Keyboard
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: splitTap.pressed ? "#3daee9" : (root.isSplit ? "#2d3848" : "#23272e")
                radius: 8
                border.color: root.isSplit ? "#3daee9" : "#3e4452"
                border.width: root.isSplit ? 2 : 1

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 4

                    Kirigami.Icon {
                        source: "view-split"
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 26
                        Layout.preferredHeight: 26
                    }

                    Text {
                        text: "Split Keyboard"
                        color: "#ffffff"
                        font.pixelSize: 12
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: root.isSplit ? "ON" : "OFF"
                        color: root.isSplit ? "#3daee9" : "#8a93a5"
                        font.pixelSize: 11
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                TapHandler {
                    id: splitTap
                    onTapped: root.isSplit = !root.isSplit
                }
            }

            // 2. Top Number Row
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: numTap.pressed ? "#3daee9" : (root.showNumberRow ? "#2d3848" : "#23272e")
                radius: 8
                border.color: root.showNumberRow ? "#3daee9" : "#3e4452"
                border.width: root.showNumberRow ? 2 : 1

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 4

                    Kirigami.Icon {
                        source: "format-list-ordered"
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 26
                        Layout.preferredHeight: 26
                    }

                    Text {
                        text: "Top 123 Number Row"
                        color: "#ffffff"
                        font.pixelSize: 12
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: root.showNumberRow ? "ON" : "OFF"
                        color: root.showNumberRow ? "#3daee9" : "#8a93a5"
                        font.pixelSize: 11
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                TapHandler {
                    id: numTap
                    onTapped: root.showNumberRow = !root.showNumberRow
                }
            }

            // 3. Keyboard Layout
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: langTap.pressed ? "#3daee9" : "#23272e"
                radius: 8
                border.color: "#3e4452"

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 4

                    Kirigami.Icon {
                        source: "language"
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 26
                        Layout.preferredHeight: 26
                    }

                    Text {
                        text: "Layout: " + root.layoutMode
                        color: "#ffffff"
                        font.pixelSize: 12
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "Tap to Switch"
                        color: "#3daee9"
                        font.pixelSize: 10
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                TapHandler {
                    id: langTap
                    onTapped: {
                        root.layoutIndex = (root.layoutIndex + 1) % root.availableLayouts.length;
                        root.layoutMode = root.availableLayouts[root.layoutIndex];
                        if (typeof swypeEngine !== "undefined" && swypeEngine) {
                            if (root.layoutMode === "QWERTZ") swypeEngine.setLanguage("de_DE");
                            else if (root.layoutMode === "AZERTY") swypeEngine.setLanguage("fr_FR");
                            else swypeEngine.setLanguage("en_GB");
                        }
                    }
                }
            }

            // 4. Gboard Theme Palette
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: themeTap.pressed ? "#3daee9" : "#23272e"
                radius: 8
                border.color: "#3e4452"

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 4

                    Kirigami.Icon {
                        source: "preferences-desktop-theme"
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 26
                        Layout.preferredHeight: 26
                    }

                    Text {
                        text: "Theme Palette"
                        color: "#ffffff"
                        font.pixelSize: 12
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Rectangle {
                        width: 18
                        height: 18
                        radius: 9
                        color: root.currentThemeColor
                        border.color: "#ffffff"
                        border.width: 1
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                TapHandler {
                    id: themeTap
                    onTapped: root.themeIndex = (root.themeIndex + 1) % root.themeColors.length
                }
            }

            // 5. One-Handed Mode
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: handTap.pressed ? "#3daee9" : (root.isOneHanded ? "#2d3848" : "#23272e")
                radius: 8
                border.color: root.isOneHanded ? "#3daee9" : "#3e4452"
                border.width: root.isOneHanded ? 2 : 1

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 4

                    Kirigami.Icon {
                        source: "hand"
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 26
                        Layout.preferredHeight: 26
                    }

                    Text {
                        text: "One-Handed"
                        color: "#ffffff"
                        font.pixelSize: 12
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: root.isOneHanded ? root.oneHandedSide.toUpperCase() : "OFF"
                        color: root.isOneHanded ? "#3daee9" : "#8a93a5"
                        font.pixelSize: 11
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                TapHandler {
                    id: handTap
                    onTapped: {
                        if (!root.isOneHanded) {
                            root.isOneHanded = true;
                            root.oneHandedSide = "right";
                        } else if (root.oneHandedSide === "right") {
                            root.oneHandedSide = "left";
                        } else {
                            root.isOneHanded = false;
                        }
                    }
                }
            }

            // 6. Freeform Floating Window
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: floatTap.pressed ? "#3daee9" : (root.isFloating ? "#2d3848" : "#23272e")
                radius: 8
                border.color: root.isFloating ? "#3daee9" : "#3e4452"
                border.width: root.isFloating ? 2 : 1

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 4

                    Kirigami.Icon {
                        source: "window-pop-out"
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 26
                        Layout.preferredHeight: 26
                    }

                    Text {
                        text: "Floating Window"
                        color: "#ffffff"
                        font.pixelSize: 12
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: root.isFloating ? "ON" : "OFF"
                        color: root.isFloating ? "#3daee9" : "#8a93a5"
                        font.pixelSize: 11
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                TapHandler {
                    id: floatTap
                    onTapped: {
                        root.isFloating = !root.isFloating;
                        settingsPanel.closeRequested();
                    }
                }
            }
        }
    }
}
