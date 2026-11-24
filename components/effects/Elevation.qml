import QtQuick
import QtQuick.Effects
import qs.components
import qs.services

RectangularShadow {
    property int level
    property real dp: [0, 1, 3, 6, 8, 12][level]

    // Ubuntu 26.04 compat: RectangularShadow gained per-corner radii in
    // Qt 6.11. Ubuntu ships 6.10.2, so accept and ignore them - the shadow
    // falls back to the uniform `radius`. Cosmetic only.
    property real topLeftRadius: radius
    property real topRightRadius: radius
    property real bottomLeftRadius: radius
    property real bottomRightRadius: radius

    color: Qt.alpha(Colours.palette.m3shadow, 0.7)
    blur: (dp * 5) ** 0.7
    spread: -dp * 0.3 + (dp * 0.1) ** 2
    offset.y: dp / 2

    Behavior on dp {
        Anim {
            type: Anim.SlowEffects
        }
    }
}
