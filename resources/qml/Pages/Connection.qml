import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import "../Components"
import "../Globals"

Page
{
    property var configuration: Config[ "main" ]

    function updateConfiguration() {
    }

    contentHeight: pageContent.implicitHeight + 40

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
                property list<string> indexes: [ "host", "port", "snmpVersion", "updateDelay" ]
                fields: [
                    configuration[ "host" ],
                    configuration[ "port" ],
                    configuration[ "snmpVersion" ],
                    configuration[ "updateDelay" ],
                ]
                buttons: [
                    { highlited: true, color: Globals.accentColor, text: "Соединить", callback: () => { SNMP.updateConnection() } },
                    { highlited: true, color: Globals.errorColor, text: "Отключить", callback: () => { SNMP.dropConnection() } }
                ]
                onFieldUpdated: ( index, value ) => {
                    let newConfig = Config.current
                    configuration[ indexes[ index ] ][ "value" ] = value
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
            }

            CardComponent {
                header: "SNMP v3"
                // TODO find value from array in combobox
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
    }
}
