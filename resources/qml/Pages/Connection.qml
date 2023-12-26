import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import "../Components"
import "../Globals"
import "../wrappers.mjs" as Wrappers

Page
{
    property var configuration: ConfigManager.get()[ "main" ]
    contentHeight: pageContent.implicitHeight + 20

    Connections
    {
        target: SNMP

        function onSettingsChanged()
        {
            configuration = ConfigManager.get()[ "main" ]
        }
    }

    function updateConfigs( field, value ) {
        let newConfig = ConfigManager.current
        value = Wrappers.getFieldValue( configuration[ field ], value )
        configuration[ field ][ "value" ] = value
        newConfig[ "main" ] = configuration
        ConfigManager.current = newConfig
    }

    ColumnLayout {
        id: pageContent

        anchors.fill: parent
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        anchors.leftMargin: 20
        anchors.rightMargin: 20

        spacing: 10

        RowLayout {
            Layout.maximumWidth: 1200
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: 10

            CardComponent {
                fields: [
                    configuration[ "host" ],
                    configuration[ "port" ],
                    configuration[ "stSNMPVersion" ],
                    configuration[ "updateDelay" ],
                ]
                buttons: [
                    { highlited: true, color: Globals.accentColor, text: "Соединить", callback: () => { SNMP.updateConnection() } },
                    { highlited: true, color: Globals.errorColor, text: "Отключить", callback: () => { SNMP.dropConnection() } }
                ]
                onFieldUpdated: ( field, value ) => updateConfigs( field, value )
            }

            Item{ Layout.fillWidth: true }

        }

        RowLayout {
            Layout.maximumWidth: 1200
            Layout.alignment: Qt.AlignHCenter| Qt.AlignTop
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: 10

            CardComponent {
                header: "SNMP v2C (Community)"
                fields: [
                    configuration[ "v2_read" ],
                    configuration[ "v2_write" ],
                ]

                onFieldUpdated: ( field, value ) => updateConfigs( field, value )
            }

            CardComponent {
                header: "SNMP v3"

                fields: [
                    configuration[ "stSNMPAdministratorName" ],
                    configuration[ "authMethod" ],
                    configuration[ "stSNMPAdministratorAuthPassword" ],
                    configuration[ "stSNMPSAuthAlgo" ],
                    configuration[ "stSNMPAdministratorPrivPassword" ],
                    configuration[ "stSNMPSPrivAlgo" ],
                ]

                onFieldUpdated: ( field, value ) => updateConfigs( field, value )
            }
        }
    }
}
