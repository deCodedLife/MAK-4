import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl

import "../Globals"

TextField
{
    id: control

    property MaterialTextContainer pBackground: background
    property var value

    signal changed( string value )

    Material.containerStyle: Material.Filled
    Material.accent: Globals.accentColor

    color: Globals.textColor
    text: value

    onTextChanged: {
        if ( text === "" ) focus = false
        if ( text === "" ) return
        if ( text === value ) return
        changed( text )
    }

    Component.onCompleted: pBackground.fillColor = Globals.backgroundColor
}
