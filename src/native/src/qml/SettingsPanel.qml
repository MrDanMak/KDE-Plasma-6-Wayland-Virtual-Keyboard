import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Rectangle {
    id: settingsPanel
    color: (typeof root !== "undefined" && root.headerColor) ? root.headerColor : "#181a1d"
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
                color: (typeof root !== "undefined" && root.textColor) ? root.textColor : "#ffffff"
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
                color: splitTap.pressed ? root.accentColor : (root.isSplit ? "#2d3848" : root.keyColor)
                radius: 8
                border.color: root.isSplit ? root.accentColor : "#3e4452"
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
                        color: root.textColor
                        font.pixelSize: 12
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: root.isSplit ? "ON" : "OFF"
                        color: root.isSplit ? root.accentColor : "#8a93a5"
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
                color: numTap.pressed ? root.accentColor : (root.showNumberRow ? "#2d3848" : root.keyColor)
                radius: 8
                border.color: root.showNumberRow ? root.accentColor : "#3e4452"
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
                        color: root.textColor
                        font.pixelSize: 12
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: root.showNumberRow ? "ON" : "OFF"
                        color: root.showNumberRow ? root.accentColor : "#8a93a5"
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
                color: langTap.pressed ? root.accentColor : root.keyColor
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
                        color: root.textColor
                        font.pixelSize: 12
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "Tap to Switch"
                        color: root.accentColor
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
                color: themeTap.pressed ? root.accentColor : root.keyColor
                radius: 8
                border.color: root.accentColor
                border.width: 2

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
                        text: root.currentPalette ? root.currentPalette.name : "Theme Palette"
                        color: root.textColor
                        font.pixelSize: 12
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Rectangle {
                        width: 18
                        height: 18
                        radius: 9
                        color: root.accentColor
                        border.color: "#ffffff"
                        border.width: 1
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                TapHandler {
                    id: themeTap
                    onTapped: root.themeIndex = (root.themeIndex + 1) % root.themePalettes.length
                }
            }

            // 5. One-Handed Mode
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: handTap.pressed ? root.accentColor : (root.isOneHanded ? "#2d3848" : root.keyColor)
                radius: 8
                border.color: root.isOneHanded ? root.accentColor : "#3e4452"
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
                        color: root.textColor
                        font.pixelSize: 12
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: root.isOneHanded ? root.oneHandedSide.toUpperCase() : "OFF"
                        color: root.isOneHanded ? root.accentColor : "#8a93a5"
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
        }
    }
}
