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

        function onSettingsChanged()
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

            fields: {
                let _fields = []

                let blvd0 = configuration[ "stBLVDDisconnectedVoltage" ]
                blvd0[ "wrapper" ] = Wrappers.divideByHundred
                _fields.push( blvd0 )
                let blvd1 = configuration[ "stLLVD1DisconnectedVoltage" ]
                blvd1[ "wrapper" ] = Wrappers.divideByHundred
                _fields.push( blvd1 )
                let blvd2 = configuration[ "stLLVD1DisconnectedVoltage" ]
                blvd1[ "wrapper" ] = Wrappers.divideByHundred
                _fields.push( blvd2 )
                let blvd3 = configuration[ "stLLVD1DisconnectedVoltage" ]
                blvd1[ "wrapper" ] = Wrappers.divideByHundred
                _fields.push( blvd3 )


                _fields.push( configuration[ "stBLVDDisconnectedTime" ] )
                _fields.push( configuration[ "stLLVD1DisconnectedTime" ] )
                _fields.push( configuration[ "stLLVD2DisconnectedTime" ] )
                _fields.push( configuration[ "stLLVD3DisconnectedTime" ] )

                _fields.push( configuration[ "stBLVDDisconnectedCapacity" ] )
                _fields.push( configuration[ "stLLVD1DisconnectedCapacity" ] )
                _fields.push( configuration[ "stLLVD2DisconnectedCapacity" ] )
                _fields.push( configuration[ "stLLVD3DisconnectedCapacity" ] )

                return _fields
            }
            onFieldUpdated: ( field, value ) => updateConfig( field, value )
        }
    }
}
