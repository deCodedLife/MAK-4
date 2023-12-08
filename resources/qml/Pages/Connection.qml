import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import "../Components"
import "../Globals"

Page
{
    property var configuration: ConfigManager.get()[ "main" ]

    contentHeight: pageContent.implicitHeight + 20

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
                onFieldUpdated: ( field, value ) => {
                    let newConfig = ConfigManager.current
                    console.log( field, value )
                    configuration[ field ][ "value" ] = value
                    newConfig[ "main" ] = configuration
                    ConfigManager.current = newConfig
                }
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
                    configuration[ "v2_write" ],
                    configuration[ "v2_write" ],
                ]

                onFieldUpdated: ( field, value ) => {
                    let newConfig = ConfigManager.current
                    configuration[ field ][ "value" ] = value
                    newConfig[ "main" ] = configuration
                    ConfigManager.current = newConfig
                }
            }

            CardComponent {
                header: "SNMP v3"
                // TODO find value from array in combobox
                fields: [
                    configuration[ "stSNMPAdministratorName" ],
                    configuration[ "authMethod" ],
                    configuration[ "stSNMPAdministratorAuthPassword" ],
                    configuration[ "stSNMPSAuthAlgo" ],
                    configuration[ "stSNMPAdministratorPrivPassword" ],
                    configuration[ "stSNMPSPrivAlgo" ],
                ]

                onFieldUpdated: ( field, value ) => {
                    let newConfig = ConfigManager.current
                    configuration[ field ][ "value" ] = value
                    newConfig[ "main" ] = configuration
                    ConfigManager.current = newConfig
                }
            }
        }
    }
}
