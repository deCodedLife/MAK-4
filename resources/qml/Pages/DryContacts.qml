import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import "../Components"
import "../Globals"

Page
{
    contentHeight: content.implicitHeight + 20

    function addWrapper( config, wrapper ) {
        config[ "wrapper" ] = wrapper
        return config
    }

    ColumnLayout {
        id: content

        anchors.fill: parent
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        anchors.leftMargin: 20
        anchors.rightMargin: 20

        TableComponent {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.maximumWidth: 1200

            headers: [
                { "title": "№ сухого\nконтакта", "expand": true },
                { "title": "Состояние", "expand": true }
            ]

            content: {
                let objects = SNMP.getBulk( "psSwitchEntry" )
                let fields = []
                let middle = objects.length / 2

                for ( let index = 0; index < middle; index++ ) {
                    fields.push( { type: 5, value: objects[ index ] } )
                    fields.push( addWrapper( { type: 5, value: objects[ middle * 1 + index  ] }, value => {
                        if ( parseInt( value ) === 0 ) return "Норма"
                        if ( parseInt( value ) === 1 ) return "Авария"
                        if ( parseInt( value ) === 2 ) return "Ошибка"
                        return value
                    } ) )
                }
                return fields
            }
        }
    }
}
