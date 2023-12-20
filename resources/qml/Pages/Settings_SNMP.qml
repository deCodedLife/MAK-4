import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import "../Components"
import "../Globals"
import "../wrappers.mjs" as Wrappers

Page
{
    property var configuration: ConfigManager.get()[ "snmp" ]
    contentHeight: pageContent.implicitHeight + 20

    actionButtonIcon: "qrc:/images/icons/save.svg"
    actionButtonTitle: "Записать"

    onActionButtonTriggered: SNMP.setMultiple( configuration )

    function updateConfig( field, value ) {
        let newConfig = ConfigManager.current
        configuration[ field ][ "value" ] = Wrappers.getFieldValue( configuration[ field ], value )
        newConfig[ "snmp" ] = configuration
        ConfigManager.current = newConfig
    }

    Connections
    {
        target: SNMP

        function onGotSettings()
        {
            configuration = ConfigManager.get()[ "snmp" ]
        }
    }

    ColumnLayout {
        id: pageContent

        anchors.fill: parent
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        anchors.leftMargin: 20
        anchors.rightMargin: 20

        spacing: 10

        CardComponent {
            Layout.maximumWidth: 1200
            Layout.alignment: Qt.AlignHCenter| Qt.AlignTop
            Layout.fillWidth: true

            fields: [
                configuration[ "stSNMPVersion" ]
            ]
            onFieldUpdated: ( field, value ) => updateConfig( field, value )
        }

        RowLayout {
            Layout.maximumWidth: 1200
            Layout.alignment: Qt.AlignHCenter| Qt.AlignTop
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: 10

            CardComponent {
                fields: [
                    configuration[ `stSNMPAdministratorName` ],
                    configuration[ `stSNMPAdministratorAuthPassword` ],
                    configuration[ `stSNMPAdministratorPrivPassword` ]
                ]

                onFieldUpdated: ( field, value ) => updateConfig( field, value )
            }

            CardComponent {
                fields: [
                    configuration[ `stSNMPEngineerName` ],
                    configuration[ `stSNMPEngineerAuthPassword` ],
                    configuration[ `stSNMPEngineerPrivPassword` ]
                ]

                onFieldUpdated: ( field, value ) => updateConfig( field, value )
            }

            CardComponent {
                fields: [
                    configuration[ `stSNMPOperatorName` ],
                    configuration[ `stSNMPOperatorAuthPassword` ],
                    configuration[ `stSNMPOperatorPrivPassword` ]
                ]

                onFieldUpdated: ( field, value ) => updateConfig( field, value )
            }
        }


        RowLayout {
            Layout.maximumWidth: 1200
            Layout.alignment: Qt.AlignHCenter| Qt.AlignTop
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: 10

            CardComponent {
                fields: [
                    configuration[ "stSNMPSAuthAlgo" ],
                    configuration[ "stSNMPSPrivAlgo" ],
                ]

                onFieldUpdated: ( field, value ) => updateConfig( field, value )
            }

            CardComponent {
                fields: [
                    configuration[ "stSNMPReadComunity" ],
                    configuration[ "stSNMPWriteComunity" ],
                ]

                onFieldUpdated: ( field, value ) => updateConfig( field, value )
            }
        }

        RowLayout {
            Layout.maximumWidth: 1200
            Layout.alignment: Qt.AlignHCenter| Qt.AlignTop
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: 10

            Repeater
            {
                model: 3

                ColumnLayout
                {
                    Text {
                        text: `IP trap-сервера #${index + 1}`
                        font.pointSize: Globals.h5
                    }

                    CardComponent {
                        fields: [
                            configuration[ `stSNMPTrap${index + 1}ServerIP` ],
                            configuration[ `stSNMPTrap${index + 1}Enable` ],
                        ]

                        onFieldUpdated: ( field, value ) => updateConfig( field, value )
                    }
                }
            }
        }
    }
}
