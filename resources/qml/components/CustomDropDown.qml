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
    model: {
        let _model = []
        let keys = Object.keys( parent.model ?? [] )
        for ( let index = 0; index < keys.length; index++ )
            _model.push( parent.model[ keys[ index ] ] )
        return _model
    }

    Material.accent: Globals.accentColor

    function find() {
        if ( model.length === 0 ) return
        let _keys = Object.keys( parent.model ?? [] )

        for ( let index = 0; index < _keys.length; index++ ) {
            let keyName = _keys[ index ]
            if ( parseInt( keyName ) === value ) {
                preSelected = index
                currentIndex = index
                break
            }
        }

        displayText = `${parent.placeholder ?? ""}: ` + ( model[ preSelected ] ?? "" )
    }

    onModelChanged: find()
    onCurrentIndexChanged: {
        if ( preSelected === currentIndex ) return
        let keys = Object.keys( parent.model ?? {} )

        for ( let index = 0; index < keys.length; index++ ) {
            let currentValue = keys[ index ]
            if ( parent.model[ currentValue ] === model[ currentIndex ] ) {
                parent.updateField( currentValue )
                preSelected = currentIndex
                parent.value = currentValue
                find()

                return
            }
        }
    }

    Component.onCompleted: {
        pTextItem.color = Globals.textColor
        pComboBack.filled = true
        pComboBack.fillColor = Globals.backgroundColor
    }
}
