pragma ComponentBehavior: Bound

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
    // The original vertical bar owns its menus. Floating topbar needs a native menu anchor.
    property bool nativeMenuOnRightClick: false

    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    implicitWidth: Tokens.font.body.small.pointSize * 2
    implicitHeight: Tokens.font.body.small.pointSize * 2

    onClicked: event => {
        if (event.button === Qt.LeftButton) {
            if (nativeMenuOnRightClick && modelData.onlyMenu && modelData.hasMenu)
                nativeMenu.open();
            else
                modelData.activate();
        } else if (event.button === Qt.RightButton) {
            if (nativeMenuOnRightClick && modelData.hasMenu)
                nativeMenu.open();
            else
                modelData.secondaryActivate();
        } else if (event.button === Qt.MiddleButton) {
            modelData.secondaryActivate();
        }
    }

    QsMenuAnchor {
        id: nativeMenu
        menu: root.modelData.menu
        anchor.item: root
        anchor.edges: Edges.Bottom | Edges.Left
        anchor.gravity: Edges.Bottom | Edges.Right
        anchor.adjustment: PopupAdjustment.Flip
    }

    ColouredIcon {
        id: icon

        anchors.fill: parent
        source: Icons.getTrayIcon(root.modelData.id, root.modelData.icon)
        colour: Colours.palette.m3secondary
        layer.enabled: Config.bar.tray.recolour
    }
}
