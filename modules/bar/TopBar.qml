pragma ComponentBehavior: Bound

// Experimental horizontal bar: three independent layer-shell windows.
// The original drawers and their popouts are intentionally left untouched.
import QtQuick
import Quickshell
import Quickshell.Wayland
import Caelestia.Config
import qs.components.containers
import qs.services

Variants {
    model: Screens.screens

    Scope {
        id: scope
        required property ShellScreen modelData

        readonly property int edgeGap: 14
        readonly property int pillHeight: 36
        readonly property color pillColour: Colours.tPalette.m3surfaceContainer
        readonly property color inkColour: Colours.palette.m3onSurface

        StyledWindow {
            name: "topbar-clock"
            screen: scope.modelData
            anchors.top: true
            anchors.left: true
            anchors.topMargin: scope.edgeGap
            anchors.leftMargin: scope.edgeGap
            implicitWidth: 165
            implicitHeight: scope.pillHeight
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: scope.pillColour

                Text {
                    anchors.centerIn: parent
                    color: scope.inkColour
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    text: Time.format("ddd d MMM  HH:mm")
                }
            }
        }

        StyledWindow {
            id: workspacesWindow
            name: "topbar-workspaces"
            screen: scope.modelData
            anchors.top: true
            anchors.left: true
            anchors.topMargin: scope.edgeGap
            anchors.leftMargin: Math.round((scope.modelData.width - implicitWidth) / 2)
            implicitWidth: Math.max(140, Config.bar.workspaces.shown * 33 + 20)
            implicitHeight: scope.pillHeight
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: scope.pillColour

                Row {
                    anchors.centerIn: parent
                    spacing: 5

                    Repeater {
                        model: Config.bar.workspaces.shown

                        Rectangle {
                            required property int index
                            readonly property int groupStart: Math.floor((Hypr.activeWsId - 1) / Config.bar.workspaces.shown) * Config.bar.workspaces.shown
                            readonly property int workspaceId: groupStart + index + 1
                            readonly property bool active: Hypr.activeWsId === workspaceId
                            width: 28
                            height: 26
                            radius: 13
                            color: active ? Colours.palette.m3primary : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: parent.workspaceId
                                color: parent.active ? Colours.palette.m3onPrimary : scope.inkColour
                                font.pixelSize: 12
                                font.weight: parent.active ? Font.DemiBold : Font.Normal
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Hypr.dispatch(Hypr.usingLua
                                    ? `hl.dsp.focus({ workspace = "${parent.workspaceId}" })`
                                    : `workspace ${parent.workspaceId}`)
                            }
                        }
                    }
                }
            }
        }

        StyledWindow {
            name: "topbar-status"
            screen: scope.modelData
            anchors.top: true
            anchors.right: true
            anchors.topMargin: scope.edgeGap
            anchors.rightMargin: scope.edgeGap
            implicitWidth: 122
            implicitHeight: scope.pillHeight
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: scope.pillColour

                Row {
                    anchors.centerIn: parent
                    spacing: 12

                    Text {
                        text: Audio.muted ? "󰝟" : "󰕾"
                        color: scope.inkColour
                        font.pixelSize: 16

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (Audio.sink?.audio)
                                    Audio.sink.audio.muted = !Audio.sink.audio.muted;
                            }
                            onWheel: event => {
                                if (event.angleDelta.y > 0)
                                    Audio.incrementVolume();
                                else if (event.angleDelta.y < 0)
                                    Audio.decrementVolume();
                            }
                        }
                    }

                    Text {
                        text: Math.round(Audio.volume * 100) + "%"
                        color: scope.inkColour
                        font.pixelSize: 12
                    }

                    Text {
                        text: Nmcli.activeEthernet ? "󰈀" : Nmcli.active ? "󰖩" : "󰖪"
                        color: scope.inkColour
                        font.pixelSize: 16
                    }
                }
            }
        }
    }
}
