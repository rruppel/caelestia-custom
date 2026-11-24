import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    // -1 means no reading yet (or NVIDIA metrics unavailable).
    property real cpu: -1
    property real ram: -1
    property real gpu: -1
    property real vram: -1
    property real disk: -1

    Process {
        id: metricProcess
        command: ["/usr/bin/python3", Quickshell.env("HOME") + "/.config/quickshell/caelestia/modules/systemMonitor/caelestia-metrics"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text.trim());
                    root.cpu = typeof data.cpu === "number" ? data.cpu : -1;
                    root.ram = typeof data.ram === "number" ? data.ram : -1;
                    root.gpu = typeof data.gpu === "number" ? data.gpu : -1;
                    root.vram = typeof data.vram === "number" ? data.vram : -1;
                    root.disk = typeof data.disk === "number" ? data.disk : -1;
                } catch (error) {
                    console.warn("system-monitor: invalid metrics:", error);
                }
            }
        }
    }

    Component.onCompleted: metricProcess.running = true

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            if (!metricProcess.running)
                metricProcess.running = true;
        }
    }

    PanelWindow {
        id: panel
        screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
        anchors {
            top: true
            right: true
        }
        margins {
            top: 55
            right: 26
        }
        implicitWidth: 204
        implicitHeight: 306
        exclusionMode: ExclusionMode.Ignore
        aboveWindows: false
        focusable: false
        color: "transparent"

        Rectangle {
            id: card
            anchors.fill: parent
            radius: 19
            color: "#E91B2941"
            border.width: 1
            border.color: "#536B8C"

            Column {
                anchors.fill: parent
                anchors.margins: 17
                spacing: 13

                Row {
                    width: parent.width
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
                        text: "SYSTEM"
                        color: "#E6F0FF"
                        font.family: "Rubik"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        font.letterSpacing: 1.8
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MetricRow {
                    width: parent.width
                    metricName: "CPU"
                    percentage: root.cpu
                    accentColor: "#8CC9FF"
                }

                MetricRow {
                    width: parent.width
                    metricName: "RAM"
                    percentage: root.ram
                    accentColor: "#86D6CE"
                }

                MetricRow {
                    width: parent.width
                    metricName: "GPU"
                    percentage: root.gpu
                    accentColor: "#A8B5FF"
                }

                MetricRow {
                    width: parent.width
                    metricName: "VRAM"
                    percentage: root.vram
                    accentColor: "#B4A0FA"
                }

                MetricRow {
                    width: parent.width
                    metricName: "DISK"
                    percentage: root.disk
                    accentColor: "#F2BC8C"
                }
            }
        }
    }
}
