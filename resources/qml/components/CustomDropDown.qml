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

    property int preSelected: -1
    currentIndex: preSelected

    Material.accent: Globals.accentColor

//    function find() {
//        for ( let index = 0; index < model.length; index++ ) {
//            if ( model[ index ] === value ) {
//                preSelected = index
//                break
//            }
//        }
//    }

    Component.onCompleted: {
        pTextItem.color = "#8D8D8D"
        pComboBack.filled = true
        pComboBack.fillColor = "#F5F8FA"
//        find()
    }
}
