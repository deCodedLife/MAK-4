import QtQuick
import QtQuick.Layouts

import "../Components"
import "../Globals"

Page
{
    contentHeight: content.implicitHeight

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

            header: "Таблица аварий 1-й степени"

            headers: [
                { "title": "Номер реле", "expand": false },
                { "title": "Количество событий", "expand": true }
            ]

            content: {
                let objects = SNMP.getBulk( "psAlarm1Event" )
                let fields = []
                for ( let index = 0; index < objects.length; index ++ ) {
                    fields.push( { type: 5, value: index + 1 } )
                    fields.push( { type: 5, value: Config[ "errors" ][ objects[ index ] ] } )
                }
                return fields
            }
        }
    }
}
