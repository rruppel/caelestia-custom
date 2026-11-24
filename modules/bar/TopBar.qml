pragma ComponentBehavior: Bound

// Floating capsule top bar with interactive app tray and system shortcuts.
import "components"
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.UPower
import Quickshell.Services.SystemTray
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.services
import qs.modules.nexus

Variants {
    model: Screens.screens

    Scope {
        id: scope
        required property ShellScreen modelData

        readonly property int edgeGap: 12
        readonly property int leftInset: 24
        readonly property int gap: 8
        readonly property int alertsWidth: 52
        readonly property int clockWidth: 165
        readonly property int logoWidth: 34
        readonly property int netWidth: 34
        readonly property int soundWidth: 94
        readonly property int bellWidth: 34
        readonly property int batteryWidth: 72
        readonly property bool hasBattery: UPower.displayDevice.isLaptopBattery
        readonly property int pillHeight: 34
        readonly property color pillColour: Qt.alpha(Colours.tPalette.m3surfaceContainer, 0.94)
        readonly property color inkColour: Colours.palette.m3onSurface
        readonly property color alertAccent: "#F7AF6D"
        readonly property color volumeAccent: "#6CD8C9"
        readonly property color networkAccent: "#7CA9FF"
        readonly property color bluetoothAccent: "#BAA5FC"
        readonly property color bellAccent: "#D6B4FF"
        readonly property color powerAccent: "#FF8D89"
        readonly property int powerWidth: 34
        readonly property int bluetoothWidth: 34
        readonly property var trayEntries: SystemTray.items.values.filter(i => !GlobalConfig.bar.tray.hiddenIcons.includes(i.id))
        readonly property int trayWidth: trayEntries.length > 0 ? 14 + trayEntries.length * 26 : 0
        readonly property int traySpace: trayEntries.length > 0 ? trayWidth + gap : 0
        readonly property int afterPower: edgeGap + powerWidth + gap
        readonly property int afterBell: afterPower + bellWidth + gap
        readonly property int afterBattery: afterBell + (hasBattery ? batteryWidth + gap : 0)
        readonly property int afterNetwork: afterBattery + netWidth + gap
        readonly property int afterBluetooth: afterNetwork + bluetoothWidth + gap
        readonly property int afterAudio: afterBluetooth + soundWidth + gap


        StyledWindow {
            name: "topbar-logo"
            screen: scope.modelData
            anchors.top: true
            anchors.left: true
            margins.top: scope.edgeGap
            margins.left: scope.leftInset
            implicitWidth: scope.logoWidth
            implicitHeight: scope.pillHeight
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: scope.pillColour
                OsIcon {
                    anchors.centerIn: parent
                }
            }
        }

        StyledWindow {
            name: "topbar-clock"
            screen: scope.modelData
            anchors.top: true
            anchors.left: true
            margins.top: scope.edgeGap
            margins.left: scope.leftInset + scope.logoWidth + scope.gap
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
            margins.left: scope.leftInset + scope.logoWidth + scope.clockWidth + 2 * scope.gap
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
                        color: scope.alertAccent
                    }
                    Text {
                        text: Notifs.notClosed.length
                        color: scope.inkColour
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        height: parent.height
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        const s = ShellState.forScreen(scope.modelData);
                        if (s)
                            s.sidebar = !s.sidebar;
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
            implicitWidth: Math.max(148, GlobalConfig.bar.workspaces.shown * 30 + 16)
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
                        model: GlobalConfig.bar.workspaces.shown

                        Rectangle {
                            required property int index
                            readonly property int groupStart: Math.floor((Hypr.activeWsId - 1) / GlobalConfig.bar.workspaces.shown) * GlobalConfig.bar.workspaces.shown
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
                                onWheel: event => {
                                    const direction = event.angleDelta.y > 0 ? "-" : "+";
                                    Hypr.dispatch(Hypr.usingLua
                                        ? `hl.dsp.focus({ workspace = "r${direction}1" })`
                                        : `workspace r${direction}1`);
                                }
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
            margins.right: scope.afterBluetooth
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
                        color: scope.volumeAccent
                    }
                    Text {
                        text: Math.round(Audio.volume * 100) + "%"
                        color: scope.inkColour
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        height: parent.height
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: event => {
                        if (event.button === Qt.RightButton) {
                            WindowFactory.createPage(3);
                        } else if (Audio.sink?.audio) {
                            Audio.sink.audio.muted = !Audio.sink.audio.muted;
                        }
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
            margins.right: scope.afterBattery
            implicitWidth: scope.netWidth
            implicitHeight: scope.pillHeight
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: scope.pillColour
                MaterialIcon {
                    anchors.centerIn: parent
                    text: Nmcli.activeEthernet ? "cable" : Nmcli.active ? "wifi" : "wifi_off"
                    color: scope.networkAccent
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: WindowFactory.createPage(1)
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
            margins.right: scope.afterBell
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
            margins.right: scope.afterPower
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
                    color: scope.bellAccent
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        const s = ShellState.forScreen(scope.modelData);
                        if (s)
                            s.sidebar = !s.sidebar;
                    }
                    onPressAndHold: Notifs.dnd = !Notifs.dnd
                }
            }
        }

        // Keep the original system-tray actions (left click / secondary click).
        // A separate pill avoids changing the existing vertical tray implementation.
        StyledWindow {
            name: "topbar-tray"
            screen: scope.modelData
            visible: scope.trayEntries.length > 0
            anchors.top: true
            anchors.right: true
            margins.top: scope.edgeGap
            margins.right: scope.afterAudio
            implicitWidth: Math.max(1, scope.trayWidth)
            implicitHeight: scope.pillHeight
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: scope.pillColour

                Row {
                    anchors.centerIn: parent
                    spacing: 0

                    Repeater {
                        model: ScriptModel {
                            values: scope.trayEntries
                        }
                        TopTrayItem {
                            width: 26
                            height: 26
                        }
                    }
                }
            }
        }

        StyledWindow {
            name: "topbar-bluetooth"
            screen: scope.modelData
            anchors.top: true
            anchors.right: true
            margins.top: scope.edgeGap
            margins.right: scope.afterNetwork
            implicitWidth: scope.bluetoothWidth
            implicitHeight: scope.pillHeight
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: scope.pillColour

                MaterialIcon {
                    anchors.centerIn: parent
                    text: "bluetooth"
                    color: scope.bluetoothAccent
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: WindowFactory.createPage(2)
                }
            }
        }

        StyledWindow {
            name: "topbar-power"
            screen: scope.modelData
            anchors.top: true
            anchors.right: true
            margins.top: scope.edgeGap
            margins.right: scope.edgeGap
            implicitWidth: scope.powerWidth
            implicitHeight: scope.pillHeight
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: scope.pillColour

                MaterialIcon {
                    anchors.centerIn: parent
                    text: "power_settings_new"
                    color: scope.powerAccent
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        const state = ShellState.forScreen(scope.modelData);
                        if (state)
                            state.session = !state.session;
                    }
                }
            }
        }
    }
}
