pragma ComponentBehavior: Bound

// Floating capsule top bar with interactive app tray and system shortcuts.
import "components"
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
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
        // Show only the minimized windows in special:magic; hide when empty.
        readonly property var scratchWindows: Hypr.toplevels.values.filter(t =>
            t.workspace?.name === "special:magic" && t.lastIpcObject?.mapped)
        readonly property int scratchWidth: scratchWindows.length > 0 ? 14 + scratchWindows.length * 28 : 0
        // Keep desktops → SnapZones → scratchpad as one horizontally centred group.
        readonly property int workspaceWidth: Math.max(148, GlobalConfig.bar.workspaces.shown * 30 + 16)
        readonly property int centerGroupWidth: workspaceWidth + gap + 34 +
            (scratchWindows.length > 0 ? gap + scratchWidth : 0)
        readonly property int centerGroupLeft: Math.round((modelData.width - centerGroupWidth) / 2)

        function restoreScratchWindow(address: string): void {
            const targetWorkspace = Hypr.activeWsId;
            if (!address || targetWorkspace < 1)
                return;
            Hypr.dispatch(`movetoworkspacesilent ${targetWorkspace},address:${address}`);
            Hypr.dispatch(`focuswindow address:${address}`);
        }

        // Manual snap selector: clicking this capsule never changes normal window dragging.
        Process {
            id: openSnapZones
            command: ["/usr/bin/qs", "-c", "caelestia", "ipc", "call", "snapzones", "toggle"]
        }



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
                        height: 24
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

        // Quick launcher for the installed GTK file manager (Thunar).
        Process {
            id: openFileManager
            command: ["thunar"]
        }

        StyledWindow {
            name: "topbar-file-manager"
            screen: scope.modelData
            anchors.top: true
            anchors.left: true
            margins.top: scope.edgeGap
            margins.left: scope.leftInset + scope.logoWidth + scope.clockWidth + scope.alertsWidth + 3 * scope.gap
            implicitWidth: 34
            implicitHeight: scope.pillHeight
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: scope.pillColour

                MaterialIcon {
                    anchors.centerIn: parent
                    text: "folder"
                    color: scope.networkAccent
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!openFileManager.running)
                            openFileManager.running = true;
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
            margins.left: scope.centerGroupLeft
            implicitWidth: scope.workspaceWidth
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
                        height: 24
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

        // Icons of windows parked in special:magic by the yellow Hyprbars button.
        // Click an icon to restore ONLY that window to the currently active desktop.
        StyledWindow {
            name: "topbar-scratchpad"
            screen: scope.modelData
            visible: scope.scratchWindows.length > 0
            anchors.top: true
            anchors.left: true
            margins.top: scope.edgeGap
            margins.left: scope.centerGroupLeft + scope.workspaceWidth + scope.gap + 34 + scope.gap
            implicitWidth: Math.max(1, scope.scratchWidth)
            implicitHeight: scope.pillHeight
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: scope.pillColour

                Row {
                    anchors.centerIn: parent
                    spacing: 2

                    Repeater {
                        model: ScriptModel { values: scope.scratchWindows }

                        Item {
                            id: scratchItem
                            required property var modelData
                            width: 26
                            height: 26
                            readonly property string address: modelData.lastIpcObject?.address ?? ""
                            readonly property string appClass: modelData.lastIpcObject?.class ?? ""
                            readonly property string appTitle: modelData.lastIpcObject?.title ?? appClass

                            Image {
                                anchors.centerIn: parent
                                width: 21
                                height: 21
                                source: Quickshell.iconPath(scratchItem.appClass, "application-x-executable")
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: scope.restoreScratchWindow(scratchItem.address)
                            }
                        }
                    }
                }
            }
        }

        // One-click screen recording. The Python helper starts a detached
        // wf-recorder process, so a Caelestia restart does not interrupt a video.
        property bool recordingActive: false
        readonly property string recorderScript: Quickshell.env("HOME") +
            "/.config/quickshell/caelestia/scripts/screen-record-toggle.py"

        Process {
            id: recorderToggle
            command: ["/usr/bin/python3", scope.recorderScript, "toggle"]
            stdout: StdioCollector {
                onStreamFinished: {
                    const state = text.trim();
                    if (state === "recording")
                        scope.recordingActive = true;
                    else if (state === "idle")
                        scope.recordingActive = false;
                }
            }
            stderr: StdioCollector {
                onStreamFinished: {
                    if (text.trim())
                        console.warn("Caelestia recorder:", text.trim());
                }
            }
        }

        Process {
            id: recorderStatus
            command: ["/usr/bin/python3", scope.recorderScript, "status"]
            stdout: StdioCollector {
                onStreamFinished: scope.recordingActive = text.trim() === "recording"
            }
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: {
                if (!recorderStatus.running && !recorderToggle.running)
                    recorderStatus.running = true;
            }
        }

        StyledWindow {
            name: "topbar-recorder"
            screen: scope.modelData
            anchors.top: true
            anchors.left: true
            margins.top: scope.edgeGap
            // Immediately after Thunar in the left-hand group.
            margins.left: scope.leftInset + scope.logoWidth + scope.clockWidth + scope.alertsWidth + 4 * scope.gap + 34
            implicitWidth: 34
            implicitHeight: scope.pillHeight
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: scope.pillColour

                MaterialIcon {
                    anchors.centerIn: parent
                    text: scope.recordingActive ? "stop_circle" : "radio_button_checked"
                    color: scope.recordingActive ? "#FF5F57" : scope.inkColour
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!recorderToggle.running)
                            recorderToggle.running = true;
                    }
                }
            }
        }

        // Advance wallpapers in alphabetical order (A-Z), looping after the last.
        // The helper remembers its position across Caelestia restarts.
        Process {
            id: nextWallpaper
            command: [
                "/usr/bin/python3",
                Quickshell.env("HOME") + "/.config/quickshell/caelestia/scripts/next-wallpaper.py"
            ]
            stderr: StdioCollector {
                onStreamFinished: {
                    if (text.trim().length > 0)
                        console.warn("TopBar wallpaper switch:", text.trim());
                }
            }
        }

        StyledWindow {
            name: "topbar-wallpaper"
            screen: scope.modelData
            anchors.top: true
            anchors.right: true
            margins.top: scope.edgeGap
            // Immediately left of Settings in the right-hand group.
            margins.right: scope.afterAudio + scope.traySpace + 34 + scope.gap
            implicitWidth: 34
            implicitHeight: scope.pillHeight
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: scope.pillColour

                MaterialIcon {
                    anchors.centerIn: parent
                    text: "skip_next"
                    color: scope.volumeAccent
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!nextWallpaper.running)
                            nextWallpaper.running = true;
                    }
                }
            }
        }

        // Caelestia Control Center shortcut; keep it separate from system settings.
        Process {
            id: openCaelestiaSettings
            command: [Quickshell.env("HOME") + "/.local/bin/caelestia", "shell", "nexus", "open"]
        }

        StyledWindow {
            name: "topbar-settings"
            screen: scope.modelData
            anchors.top: true
            anchors.right: true
            margins.top: scope.edgeGap
            // Keep Settings on the right, independent from the centred controls.
            margins.right: scope.afterAudio + scope.traySpace
            implicitWidth: 34
            implicitHeight: scope.pillHeight
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: scope.pillColour

                MaterialIcon {
                    anchors.centerIn: parent
                    text: "settings"
                    color: scope.bluetoothAccent
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!openCaelestiaSettings.running)
                            openCaelestiaSettings.running = true;
                    }
                }
            }
        }

        StyledWindow {
            name: "topbar-snapzones"
            screen: scope.modelData
            anchors.top: true
            anchors.left: true
            margins.top: scope.edgeGap
            // Immediately after the workspaces capsule in the centred group.
            margins.left: scope.centerGroupLeft + scope.workspaceWidth + scope.gap
            implicitWidth: 34
            implicitHeight: scope.pillHeight
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: scope.pillColour

                MaterialIcon {
                    anchors.centerIn: parent
                    text: "grid_view"
                    color: scope.networkAccent
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!openSnapZones.running)
                            openSnapZones.running = true;
                    }
                }
            }
        }
    }
}
