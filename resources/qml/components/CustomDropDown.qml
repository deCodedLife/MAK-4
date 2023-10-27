import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl
import QtQuick.Templates as T

import "../Globals"

ComboBox
{
    property MaterialTextContainer pComboBack: background
    property T.TextField pTextItem: contentItem

    property var value: null
    property int preSelected: -1
    currentIndex: -1

    Material.accent: Globals.accentColor

    function find() {
        if ( model.length === 0 ) return
        for ( let index = 0; index < model.length; index++ ) {
            if ( model[ index ] === value ) {
                preSelected = index
                currentIndex = index
                break
            }
        }
    }

    Component.onCompleted: {
        pTextItem.color = Globals.textColor
        pComboBack.filled = true
        pComboBack.fillColor = Globals.backgroundColor
        find()
    }
}
