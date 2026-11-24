pragma ComponentBehavior: Bound

// Serenity, Courage and Wisdom — floating companion to the existing SYSTEM
// monitor. It deliberately does not replace or modify the standalone monitor.
import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    anchors.top: true
    anchors.right: true
    margins.top: 55
    // SYSTEM: 204px wide, 26px from right; 14px clear space between cards.
    margins.right: 26 + 204 + 14

    implicitWidth: 260
    implicitHeight: 253
    exclusionMode: ExclusionMode.Ignore
    aboveWindows: false
    focusable: false
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        radius: 19
        color: "#E91B2941"
        border.width: 1
        border.color: "#536B8C"

        Column {
            anchors.fill: parent
            anchors.margins: 17
            spacing: 10

            Row {
                height: 21
                spacing: 8

                Rectangle {
                    width: 7
                    height: 7
                    radius: 4
                    color: "#83DBB6"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "REFLEXÃO"
                    color: "#E6F0FF"
                    font.family: "Rubik"
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    font.letterSpacing: 1.8
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item { width: 1; height: 3 }

            Row {
                width: parent.width
                height: 170
                spacing: 12

                Rectangle {
                    width: 2
                    height: 164
                    radius: 1
                    color: "#87ABF7"
                    opacity: 0.7
                }

                Column {
                    width: parent.width - 14
                    spacing: 10

                    Column {
                        spacing: 2
                        Text {
                            text: "Serenidade"
                            color: "#8DC4FF"
                            font.family: "Rubik"
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                        }
                        Text {
                            text: "para aceitar o que não\nposso mudar"
                            color: "#EDF3FF"
                            font.family: "Rubik"
                            font.pixelSize: 12
                            lineHeight: 1.1
                        }
                    }

                    Column {
                        spacing: 2
                        Text {
                            text: "Coragem"
                            color: "#7BE1CE"
                            font.family: "Rubik"
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                        }
                        Text {
                            text: "para mudar o que posso"
                            color: "#EDF3FF"
                            font.family: "Rubik"
                            font.pixelSize: 12
                        }
                    }

                    Column {
                        spacing: 2
                        Text {
                            text: "Sabedoria"
                            color: "#BBA5FF"
                            font.family: "Rubik"
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                        }
                        Text {
                            text: "para reconhecer\na diferença"
                            color: "#EDF3FF"
                            font.family: "Rubik"
                            font.pixelSize: 12
                            lineHeight: 1.1
                        }
                    }
                }
            }
        }
    }
}
