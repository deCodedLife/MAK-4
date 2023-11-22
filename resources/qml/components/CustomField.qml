import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl

import "../Globals"

TextField
{
    id: control

    property MaterialTextContainer pBackground: background
    property var value: null
    Material.containerStyle: Material.Filled
    Material.accent: Globals.accentColor

    color: Globals.textColor
    text: value

    onTextChanged: {
        if ( value === "" ) focus = false
    }

    Component.onCompleted: pBackground.fillColor = Globals.backgroundColor
}
