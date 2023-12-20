import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import "../Components"
import "../Globals"
import "../wrappers.mjs" as Wrappers

Page
{
    property var configuration: ConfigManager.get()[ "network" ]
    contentHeight: pageContent.implicitHeight + 20

    actionButtonIcon: "qrc:/images/icons/save.svg"
    actionButtonTitle: "Записать"

    onActionButtonTriggered: SNMP.setMultiple( configuration )

    function updateConfig( field, value ) {
        let newConfig = ConfigManager.current
        configuration[ field ][ "value" ] = Wrappers.getFieldValue( configuration[ field ], value )
        newConfig[ "network" ] = configuration
        ConfigManager.current = newConfig
    }

    Connections
    {
        target: SNMP

        function onSettingsChanged()
        {
            configuration = ConfigManager.get()[ "network" ]
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
                configuration[ "stIPaddress" ],
                configuration[ "stNetworkMask" ],
                configuration[ "stNetworkGateway" ]
            ]
            onFieldUpdated: ( field, value ) => updateConfig( field, value )
        }
    }
}
