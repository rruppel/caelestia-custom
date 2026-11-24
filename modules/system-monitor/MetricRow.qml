import QtQuick

Column {
    id: root
    property string metricName: "CPU"
    property real percentage: -1
    property color accentColor: "#8CC9FF"

    height: 37
    spacing: 7

    Row {
        width: parent.width
        height: 16
        spacing: 4

        Text {
            id: metricLabel
            text: root.metricName
            color: "#AFC2DC"
            font.family: "Rubik"
            font.pixelSize: 11
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            width: Math.max(0, parent.width - metricLabel.width - metricValue.width - 4)
            height: 1
        }

        Text {
            id: metricValue
            text: root.percentage < 0 ? "—" : root.percentage.toFixed(0) + "%"
            color: "#F2F7FF"
            font.family: "Rubik"
            font.pixelSize: 12
            font.weight: Font.DemiBold
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Rectangle {
        width: parent.width
        height: 5
        radius: 2.5
        color: "#34455F"

        Rectangle {
            width: root.percentage < 0 ? 0 : parent.width * Math.max(0, Math.min(100, root.percentage)) / 100
            height: parent.height
            radius: parent.radius
            color: root.accentColor

            Behavior on width {
                NumberAnimation {
                    duration: 440
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}
