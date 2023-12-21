import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl

import "../Globals"
import CustomDoubleValidator 0.1
import IPAddressValidator 0.1

TextField
{
    id: control
    anchors.fill: parent

    property int type: parent.type ?? 2
    property string initValue
    property MaterialTextContainer pBackground: background

    property var adressValidator: IPAddressValidator {}
    property var counterValidator: CustomDoubleValidator {
        bottom: parent.minValue
        top: parent.maxValue
    }
    property var value: {
        if ( parent.wrapper ) return parent.wrapper( parent.value ?? "" )
        else parent.value ?? ""
    }

    placeholderText: parent.placeholder ?? ""
    Material.containerStyle: Material.Filled
    Material.accent: Globals.accentColor
    echoMode: (parent.type ?? 2) === 3 ? TextField.Password : TextField.Normal
    validator: {
        if ( !parent.type ) return null
        if ( parent.type === 6 ) return counterValidator
        if ( parent.type === 8 ) return adressValidator
        return null
    }

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

    Component.onCompleted: {
        pBackground.fillColor = Globals.backgroundColor
        if ( parent.objectName === "stMonitoringPassword" ) maximumLength = 6
    }
}
