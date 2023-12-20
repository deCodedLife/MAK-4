import QtQuick
import QtQuick.Layouts

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

        RowLayout {

            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.maximumWidth: 1200
            spacing: 10

            TableComponent {
                Layout.alignment: Qt.AlignTop
                header: "Таблица аварий 1-й степени"

                headers: [
                    { "title": "Номер", "expand": false },
                    { "title": "Название аварии 1 степени", "expand": true }
                ]

                content: {
                    let objects = SNMP.getBulk( "psAlarm1Entry" )
                    let fields = []
                    let middle = objects.length / 2

                    for ( let index = 0; index < middle; index++ ) {
                        fields.push( { type: 5, value: objects[ index ] } )
                        fields.push( { type: 5, value: Config[ "errors" ][ objects[ middle + index ] ] } )
                    }
                    return fields
                }
            }

            TableComponent {
                Layout.alignment: Qt.AlignTop
                header: "Таблица аварий 2-й степени"

                headers: [
                    { "title": "Номер", "expand": false },
                    { "title": "Название аварии 2 степени", "expand": true }
                ]

                content: {
                    let objects = SNMP.getBulk( "psAlarm2Entry" )
                    let fields = []
                    let middle = objects.length / 2

                    for ( let index = 0; index < middle; index++ ) {
                        fields.push( { type: 5, value: objects[ index ] } )
                        fields.push( { type: 5, value: Config[ "errors" ][ objects[ middle + index ] ] } )
                    }
                    return fields
                }
            }

        }
    }
}
