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

    ColumnLayout {
        id: pageContent

        anchors.fill: parent
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        anchors.leftMargin: 20
        anchors.rightMargin: 20

        spacing: 10


        CustomSwitch {
            Layout.maximumWidth: 1200
            Layout.alignment: Qt.AlignHCenter| Qt.AlignTop
            Layout.fillWidth: true

            property var field: configuration[ "stContactorControl" ]
            id: handControl
            text: field[ "description" ]
            toggled: field[ "value" ]
            dobbled: true
            onContentChanged: value => {
                let newConfig = ConfigManager.current
                configuration[ "stContactorControl" ][ "value" ] = value
                newConfig[ "blvd" ] = configuration
                ConfigManager.current = newConfig
            }
        }

        CardComponent {
            Layout.maximumWidth: 1200
            Layout.alignment: Qt.AlignHCenter| Qt.AlignTop
            Layout.fillWidth: true

            enabled: handControl.toggled

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
