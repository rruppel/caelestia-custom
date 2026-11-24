pragma ComponentBehavior: Bound

// Explicit six-zone picker, opened from the TopBar or a Hyprland keybind.
// Never hooks into or changes normal pointer-based window dragging.
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Caelestia.Config
import qs.components
import qs.services

Scope {
    id: root

    property bool selectorVisible: false

    IpcHandler {
        target: "snapzones"

        function toggle(): void {
            root.selectorVisible = !root.selectorVisible;
        }

        function hide(): void {
            root.selectorVisible = false;
        }
    }

    Process {
        id: snapper
        property int selectedZone: 1
        command: ["/usr/bin/python3",
                  Quickshell.env("HOME") + "/.config/quickshell/caelestia/modules/snapzones/snap6.py",
                  selectedZone.toString()]
        stdout: StdioCollector {
            onStreamFinished: console.info("SnapZones:", text.trim())
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0)
                    console.warn("SnapZones:", text.trim());
            }
        }
    }

    function chooseZone(zone: int): void {
        if (snapper.running)
            return;
        snapper.selectedZone = zone;
        root.selectorVisible = false;
        snapper.running = true;
    }

    // The picker is a compact layout map near the top, not a screen-sized overlay.
    Variants {
        model: Screens.screens

        PanelWindow {
            id: picker
            required property ShellScreen modelData

            screen: modelData
            visible: root.selectorVisible
            anchors.top: true
            margins.top: 65
            implicitWidth: Math.min(1120, Math.max(360, modelData.width - 48))
            implicitHeight: 222
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                radius: 18
                color: "#ED151D2D"
                border.width: 1
                border.color: "#526883"

                Text {
                    id: heading
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.leftMargin: 18
                    anchors.topMargin: 12
                    text: "POSICIONAR JANELA"
                    font.family: "Rubik"
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    font.letterSpacing: 1.2
                    color: "#DCE9FF"
                }

                Text {
                    anchors.left: heading.right
                    anchors.top: heading.top
                    anchors.leftMargin: 12
                    text: "Escolha uma das seis zonas"
                    font.family: "Rubik"
                    font.pixelSize: 11
                    color: "#93A6C3"
                }

                Rectangle {
                    id: closeButton
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 9
                    width: 27
                    height: 27
                    radius: 14
                    color: closeArea.containsMouse ? "#5C607B" : "#334157"

                    Text {
                        anchors.centerIn: parent
                        text: "×"
                        color: "#EAF0FC"
                        font.pixelSize: 20
                    }
                    MouseArea {
                        id: closeArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.selectorVisible = false
                    }
                }

                Grid {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 15
                    anchors.rightMargin: 15
                    anchors.topMargin: 44
                    anchors.bottomMargin: 15
                    columns: 3
                    rows: 2
                    columnSpacing: 10
                    rowSpacing: 10

                    Repeater {
                        model: 6

                        Rectangle {
                            id: zone
                            required property int index
                            width: Math.max(1, (parent.width - 20) / 3)
                            height: Math.max(1, (parent.height - 10) / 2)
                            radius: 9
                            color: zoneArea.containsMouse ? "#805F91E5" : "#4437475F"
                            border.width: zoneArea.containsMouse ? 2 : 1
                            border.color: zoneArea.containsMouse ? "#B4D2FF" : "#637A9F"

                            Text {
                                anchors.centerIn: parent
                                text: zone.index + 1
                                font.family: "Rubik"
                                font.pixelSize: 16
                                font.weight: Font.DemiBold
                                color: "#EDF3FF"
                            }

                            MouseArea {
                                id: zoneArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.chooseZone(zone.index + 1)
                            }
                        }
                    }
                }
            }
        }
    }
}
