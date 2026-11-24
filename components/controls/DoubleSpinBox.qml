pragma ComponentBehavior: Bound

// Compatibility shim for Ubuntu 26.04.
// QtQuick.Templates.DoubleSpinBox was introduced in Qt 6.11; Ubuntu 26.04
// ships Qt 6.10.2. This provides the subset of the API that
// components/controls/StyledSpinBox.qml relies on. Delete this file once
// Ubuntu ships Qt >= 6.11.

import QtQuick
import QtQuick.Templates as T

T.Control {
    id: control

    property real from: 0
    property real to: 99
    property real value: 0
    property real stepSize: 1
    property int decimals: 0
    property bool editable: false
    property var spinLocale: Qt.locale()

    property DoubleValidator validator: DoubleValidator {
        bottom: Math.min(control.from, control.to)
        top: Math.max(control.from, control.to)
        decimals: control.decimals
        notation: DoubleValidator.StandardNotation
    }

    signal valueModified

    function textFromValue(value: real, locale: var): string {
        return Number(value).toFixed(control.decimals);
    }

    function valueFromText(text: string, locale: var): real {
        return parseFloat(text);
    }

    // A concrete type is required: assigning `up.indicator` from outside
    // resolves against the *declared* type, and bare QtObject has no such
    // property.
    component IndicatorSlot: QtObject {
        property Item parentItem
        property Item indicator

        onIndicatorChanged: {
            if (indicator && parentItem)
                indicator.parent = parentItem;
        }
    }

    readonly property IndicatorSlot up: IndicatorSlot {
        parentItem: control
    }

    readonly property IndicatorSlot down: IndicatorSlot {
        parentItem: control
    }

    Connections {
        target: control.contentItem
        ignoreUnknownSignals: true

        function onEditingFinished(): void {
            const v = control.valueFromText(control.contentItem.text, control.spinLocale);
            if (!isNaN(v)) {
                control.value = Math.max(control.from, Math.min(control.to, v));
                control.valueModified();
            }
        }
    }
}
