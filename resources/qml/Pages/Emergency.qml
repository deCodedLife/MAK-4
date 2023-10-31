import QtQuick
import QtQuick.Layouts

import "../Components"
import "../Globals"

Page
{
    property var configuration: Config[ "fields" ]
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
                { "title": "Номер", "expand": false },
                { "title": "Название аварии 1 степени", "expand": true }
            ]

            content: [
                configuration[ "psAlarm1Event" ], // psAlarm1Entry
                configuration[ "psAlarm1Event" ] // psAlarm1Entry
            ]
        }

        Component.onCompleted: console.log( JSON.stringify( SNMP.getBulk( "psAlarm1Event" ) ) )
    }
}
