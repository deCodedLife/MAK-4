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
                configuration[ "deviceInfo0" ],
                configuration[ "psSerial" ],

                configuration[ "deviceInfo1" ],
                configuration[ "psDescription" ],

                configuration[ "deviceInfo2" ],
                addWrapper( configuration[ "psFWRevision" ], ( value ) => {
                                let stringVal = value.toString()
                                return `${stringVal[0]}.${stringVal[1]}.${stringVal[2]}`
                } ),

                configuration[ "deviceInfo3" ],
                addWrapper( configuration[ "psTime" ], ( value ) => {
                               let dateTime = SNMP.dateToReadable( value ).split( " " )
                               return `${dateTime[0]}\n${dateTime[1]}`
                           } )
            ]
        }
    }
}
