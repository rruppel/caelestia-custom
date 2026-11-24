pragma ComponentBehavior: Bound

// Experimental horizontal bar: three independent layer-shell windows.
// The original drawers and their popouts are intentionally left untouched.
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.UPower
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.services

Variants {
    model: Screens.screens

    Scope {
        id: scope
        required property ShellScreen modelData

        readonly property int edgeGap: 12
        readonly property int gap: 8
        readonly property int alertsWidth: 52
        readonly property int clockWidth: 165
        readonly property int logoWidth: 34
        readonly property int netWidth: 150
        readonly property int soundWidth: 94
        readonly property int bellWidth: 34
        readonly property int batteryWidth: 72
        readonly property bool hasBattery: UPower.displayDevice.isLaptopBattery
        readonly property int pillHeight: 34
        readonly property color pillColour: Qt.alpha(Colours.tPalette.m3surfaceContainer, 0.94)
        readonly property color inkColour: Colours.palette.m3onSurface


        StyledWindow {
            name: "topbar-logo"
            screen: scope.modelData
            anchors.top: true
            anchors.left: true
            margins.top: scope.edgeGap
            margins.left: scope.edgeGap
            implicitWidth: scope.logoWidth
            implicitHeight: scope.pillHeight
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: scope.pillColour
                Text {
                    anchors.centerIn: parent
                    text: "A"
                    font.pixelSize: 17
                    font.weight: Font.Bold
                    color: Colours.palette.m3primary
                }
            }
        }

        StyledWindow {
            name: "topbar-clock"
            screen: scope.modelData
            anchors.top: true
            anchors.left: true
            margins.top: scope.edgeGap
            margins.left: scope.edgeGap + scope.logoWidth + scope.gap
            implicitWidth: scope.clockWidth
            implicitHeight: scope.pillHeight
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: scope.pillColour
                Text {
                    anchors.centerIn: parent
                    text: Time.format("ddd d MMM  HH:mm")
                    color: scope.inkColour
                    font.pixelSize: 12
                    font.weight: Font.Medium
                }
            }
        }

        StyledWindow {
            name: "topbar-alerts"
            screen: scope.modelData
            anchors.top: true
            anchors.left: true
            margins.top: scope.edgeGap
            margins.left: scope.edgeGap + scope.logoWidth + scope.clockWidth + 2 * scope.gap
            implicitWidth: scope.alertsWidth
            implicitHeight: scope.pillHeight
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: scope.pillColour
                Row {
                    anchors.centerIn: parent
                    spacing: 4
                    MaterialIcon {
                        text: "notifications_active"
                        color: Colours.palette.m3error
                    }
                    Text {
                        text: Notifs.notClosed.length
                        color: scope.inkColour
                        font.pixelSize: 12
                    }
                }
            }
        }

        StyledWindow {
            id: workspacesWindow
            name: "topbar-workspaces"
            screen: scope.modelData
            anchors.top: true
            anchors.left: true
            margins.top: scope.edgeGap
            margins.left: Math.round((scope.modelData.width - implicitWidth) / 2)
            implicitWidth: Math.max(148, Config.bar.workspaces.shown * 30 + 16)
            implicitHeight: scope.pillHeight
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
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
                            width: 25
                            height: 25
                            radius: 13
                            color: active ? Colours.palette.m3primary : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: parent.active ? parent.workspaceId : "·"
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
            name: "topbar-audio"
            screen: scope.modelData
            anchors.top: true
            anchors.right: true
            margins.top: scope.edgeGap
            margins.right: scope.edgeGap + scope.bellWidth + scope.gap
                + (scope.hasBattery ? scope.batteryWidth + scope.gap : 0)
                + scope.netWidth + scope.gap
            implicitWidth: scope.soundWidth
            implicitHeight: scope.pillHeight
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: scope.pillColour
                Row {
                    anchors.centerIn: parent
                    spacing: 6
                    MaterialIcon {
                        text: Audio.muted ? "volume_off" : "headphones"
                        color: Colours.palette.m3primary
                    }
                    Text {
                        text: Math.round(Audio.volume * 100) + "%"
                        color: scope.inkColour
                        font.pixelSize: 12
                    }
                }
                MouseArea {
                    anchors.fill: parent
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
        }

        StyledWindow {
            name: "topbar-network"
            screen: scope.modelData
            anchors.top: true
            anchors.right: true
            margins.top: scope.edgeGap
            margins.right: scope.edgeGap + scope.bellWidth + scope.gap
                + (scope.hasBattery ? scope.batteryWidth + scope.gap : 0)
            implicitWidth: scope.netWidth
            implicitHeight: scope.pillHeight
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: scope.pillColour
                Row {
                    anchors.centerIn: parent
                    spacing: 7
                    MaterialIcon {
                        text: Nmcli.activeEthernet ? "lan" : Nmcli.active ? "wifi" : "wifi_off"
                        color: Colours.palette.m3primary
                    }
                    Text {
                        text: Nmcli.activeEthernet ? "Ethernet" : Nmcli.active ? Nmcli.active.ssid : "Offline"
                        color: scope.inkColour
                        font.pixelSize: 12
                        width: Math.min(100, implicitWidth)
                        elide: Text.ElideRight
                    }
                }
            }
        }

        StyledWindow {
            name: "topbar-battery"
            screen: scope.modelData
            visible: scope.hasBattery
            anchors.top: true
            anchors.right: true
            margins.top: scope.edgeGap
            margins.right: scope.edgeGap + scope.bellWidth + scope.gap
            implicitWidth: scope.batteryWidth
            implicitHeight: scope.pillHeight
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: scope.pillColour
                Row {
                    anchors.centerIn: parent
                    spacing: 4
                    MaterialIcon {
                        text: "battery_full"
                        color: Colours.palette.m3primary
                    }
                    Text {
                        text: Math.round(UPower.displayDevice.percentage * 100) + "%"
                        color: scope.inkColour
                        font.pixelSize: 12
                    }
                }
            }
        }

        StyledWindow {
            name: "topbar-notifications"
            screen: scope.modelData
            anchors.top: true
            anchors.right: true
            margins.top: scope.edgeGap
            margins.right: scope.edgeGap
            implicitWidth: scope.bellWidth
            implicitHeight: scope.pillHeight
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: scope.pillColour
                MaterialIcon {
                    anchors.centerIn: parent
                    text: Notifs.dnd ? "notifications_off" : "notifications"
                    color: scope.inkColour
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Notifs.dnd = !Notifs.dnd
                }
            }
        }
    }
}
