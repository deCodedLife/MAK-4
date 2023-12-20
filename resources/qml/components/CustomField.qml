import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl

import "../Globals"
import CustomDoubleValidator 0.1

TextField
{
    id: control
    anchors.fill: parent

    property string initValue
    property var counterValidator: CustomDoubleValidator {
        bottom: parent.minValue
        top: parent.maxValue
    }

    placeholderText: parent.placeholder ?? ""

    property MaterialTextContainer pBackground: background
    property var value: {
        if ( parent.wrapper ) return parent.wrapper( parent.value ?? "" )
        else parent.value ?? ""
    }

    Material.containerStyle: Material.Filled
    Material.accent: Globals.accentColor
    echoMode: (parent.type ?? 2) === 3 ? TextField.Password : TextField.Normal
    validator: (parent.type ?? 2) === 6 ? counterValidator : null

    color: (parent.type ?? 2) === 6
           ? acceptableInput ? Globals.textColor : Globals.errorColor
           : Globals.textColor

    text: value

    onTextChanged: {
        if ( !acceptableInput ) return

        // if ( text === "" ) focus = false
        if ( text === "" ) return
        if ( !initValue ) {
            initValue = text
            return
        }

        parent.updateField( text )
    }

    Component.onCompleted: pBackground.fillColor = Globals.backgroundColor
}
