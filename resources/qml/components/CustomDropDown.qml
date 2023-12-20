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

    property var value: parent.value
    property int preSelected: -1
    currentIndex: -1

    displayText: ""
    model: Object.keys( parent.model ?? [] )
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
        displayText = `${parent.placeholder ?? ""}: ` + Object.keys( parent.model ?? {} )[ currentIndex ]
    }

    onModelChanged: find()
    onCurrentIndexChanged: {
        if ( preSelected === currentIndex ) return
        parent.updateField( Object.keys( parent.model ?? [] )[ currentIndex ] )
    }

    Component.onCompleted: {
        pTextItem.color = Globals.textColor
        pComboBack.filled = true
        pComboBack.fillColor = Globals.backgroundColor
    }
}
