import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import "../Components"
import "../Globals"

Page
{
    property var configuration: Config.current[ "main" ]

    function updateConfiguration() {
        configuration[ "host" ] = `udp:${host}:${port}`
        configuration[ "updateDelay" ] = parseInt( delay )
        console.log( JSON.stringify( configuration ) )
    }

    Flickable {
        anchors.fill: parent
        interactive: height < contentHeight
        contentHeight: pageContent.implicitHeight + 40
        boundsMovement: Flickable.StopAtBounds

        ColumnLayout {
            id: pageContent

            anchors.fill: parent
            anchors.margins: {
                top: 10
                bottom: 10
                left: 20
                right: 20
            }
            spacing: 10

            RowLayout {
                Layout.maximumWidth: 1200
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.fillHeight: true

                spacing: 10

                CardComponent
                {
                    fields: [
                        configuration[ "host" ],
                        configuration[ "port" ],
                        configuration[ "snmpVersion" ],
                        configuration[ "updateDelay" ],
                    ]

                    buttons: [
                        { highlited: true, color: Globals.accentColor, text: "Соединить", callback: () => { console.log( "test" ) } },
                        { highlited: true, color: Globals.errorColor, text: "Отключить", callback: () => { console.log( "test2" ) } }
                    ]


                }

                Item{ Layout.fillWidth: true }

            }

            RowLayout {
                Layout.maximumWidth: 1200
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.fillHeight: true

                spacing: 10

                CardComponent
                {
                    header: "SNMP v2C (Community)"

                    fields: [
                        configuration[ "v2_write" ],
                        configuration[ "v2_write" ],
                    ]

                }

                CardComponent
                {
                    header: "SNMP v3"

                    fields: [
                        configuration[ "user" ],
                        configuration[ "authMethod" ],
                        configuration[ "authPassword" ],
                        configuration[ "authProtocol" ],
                        configuration[ "privPassword" ],
                        configuration[ "privProtocol" ],
                    ]
                }

            }

            Item{ Layout.fillHeight: true }
        }
    }
}
