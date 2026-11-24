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

    Variants {
        model: Screens.screens

        PanelWindow {
            id: picker
            required property ShellScreen modelData

            screen: modelData
            visible: root.selectorVisible
            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            color: "#6B081423"

            Rectangle {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 12
                width: 34
                height: 34
                radius: 17
                color: "#D71B2941"
                border.color: "#6EA8DA"
                border.width: 1
                z: 2

                Text {
                    anchors.centerIn: parent
                    text: "×"
                    font.pixelSize: 25
                    color: "#EDF3FF"
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.selectorVisible = false
                }
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: 12
                anchors.topMargin: 58
                color: "transparent"

                Grid {
                    anchors.fill: parent
                    columns: 3
                    rows: 2
                    columnSpacing: 12
                    rowSpacing: 12

                    Repeater {
                        model: 6

                        Rectangle {
                            id: zone
                            required property int index
                            width: Math.max(1, (parent.width - 24) / 3)
                            height: Math.max(1, (parent.height - 12) / 2)
                            radius: 16
                            color: hover.hovered ? "#927CA9FF" : "#573C618C"
                            border.width: hover.hovered ? 3 : 1
                            border.color: hover.hovered ? "#C5D9FF" : "#6EA8DA"

                            Text {
                                anchors.centerIn: parent
                                text: zone.index + 1
                                font.pixelSize: 30
                                font.weight: Font.DemiBold
                                color: "#FFFFFF"
                            }

                            HoverHandler { id: hover }
                            MouseArea {
                                anchors.fill: parent
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
