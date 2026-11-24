pragma ComponentBehavior: Bound

// Tray button for the floating top bar. The sidebar keeps using TrayItem.qml.
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Caelestia.Config
import qs.components.effects
import qs.services
import qs.utils

MouseArea {
    id: root

    required property SystemTrayItem modelData

    implicitWidth: 26
    implicitHeight: 26
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    cursorShape: Qt.PointingHandCursor

    onClicked: event => {
        // Report clicks in 'qs log -c caelestia --follow' for troubleshooting.
        console.info("TopBar tray clicked:", modelData.id, "button:", event.button,
                     "menu:", modelData.hasMenu, "onlyMenu:", modelData.onlyMenu);

        if (event.button === Qt.LeftButton) {
            if (modelData.hasMenu)
                menuAnchor.open();
            else
                modelData.activate();
        } else if (event.button === Qt.RightButton || event.button === Qt.MiddleButton) {
            modelData.secondaryActivate();
        }
    }

    QsMenuAnchor {
        id: menuAnchor
        menu: root.modelData.menu
        anchor.item: root
        anchor.edges: Edges.Bottom | Edges.Left
        anchor.gravity: Edges.Bottom | Edges.Right
        anchor.adjustment: PopupAdjustment.Flip
    }

    ColouredIcon {
        anchors.fill: parent
        anchors.margins: 3
        source: Icons.getTrayIcon(root.modelData.id, root.modelData.icon)
        colour: Colours.palette.m3secondary
        layer.enabled: GlobalConfig.bar.tray.recolour
    }
}
