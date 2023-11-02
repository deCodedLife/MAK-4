import QtQuick
import QtQuick.Layouts

import "../Components"
import "../Globals"

Page
{
    property var configuration: Config[ "fields" ]
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
                { "title": "Название", "expand": true },
                { "title": "Значение", "expand": false }
            ]

            content: [
                { type: 5, value: "Серийный номер источника питания" },
                { type: 4, field: "psSerial" },

                { type: 5, value: "Описание источника питания" },
                { type: 4, field: "psDescription" },

                { type: 5, value: "Версия ПО контроллера" },
                addWrapper( { type: 4, field: "psFWRevision" }, ( value ) => {
                                let stringVal = value.toString()
                                return `${stringVal[0]}.${stringVal[1]}.${stringVal[2]}`
                } ),

                { type: 5, value: "Текущее время MAK-4 UTC" },
                addWrapper( { type: 4, field: "psTime" }, value => {
                    let dateTime = SNMP.dateToReadable( value ).split( " " )
                    return `${dateTime[0]}\n${dateTime[1]}`
                } )
            ]
        }
    }
}
