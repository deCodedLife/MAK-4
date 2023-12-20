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

    color: "#8D8D8D"
    text: value

    onTextChanged: {
        if ( text == "" ) focus = false
    }

    onEditingFinished: control.value = text
    Component.onCompleted: pBackground.fillColor = Globals.backgroundColor
}
