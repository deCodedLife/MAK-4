import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import "../Components"
import "../Globals"
import "../wrappers.mjs" as Wrappers

Page
{
    property var configuration: ConfigManager.get()[ "blvd" ]
    contentHeight: pageContent.implicitHeight + 20

    actionButtonIcon: "qrc:/images/icons/save.svg"
    actionButtonTitle: "Записать"

    onActionButtonTriggered: SNMP.setMultiple( configuration )

    function updateConfig( field, value ) {
        let newConfig = ConfigManager.current
        configuration[ field ][ "value" ] = Wrappers.getFieldValue( configuration[ field ], value )
        newConfig[ "blvd" ] = configuration
        ConfigManager.current = newConfig
    }

    Connections
    {
        target: SNMP

        function onGotSettings()
        {
            configuration = ConfigManager.get()[ "blvd" ]
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
                configuration[ "stBLVDDisconnectedVoltage" ],
                configuration[ "stLLVD1DisconnectedVoltage" ],
                configuration[ "stLLVD2DisconnectedVoltage" ],
                configuration[ "stLLVD3DisconnectedVoltage" ],
                configuration[ "stBLVDDisconnectedTime" ],
                configuration[ "stLLVD1DisconnectedTime" ],
                configuration[ "stLLVD2DisconnectedTime" ],
                configuration[ "stLLVD3DisconnectedTime" ],
                configuration[ "stBLVDDisconnectedCapacity" ],
                configuration[ "stLLVD1DisconnectedCapacity" ],
                configuration[ "stLLVD2DisconnectedCapacity" ],
                configuration[ "stLLVD3DisconnectedCapacity" ]
            ]
            onFieldUpdated: ( field, value ) => updateConfig( field, value )
        }
    }
}
