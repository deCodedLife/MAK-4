import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import "../Components"
import "../Globals"
import "../wrappers.mjs" as Wrappers

Page
{
    property var configuration: ConfigManager.get()[ "temperature" ]
    contentHeight: pageContent.implicitHeight + 20

    actionButtonIcon: "qrc:/images/icons/save.svg"
    actionButtonTitle: "Записать"

    onActionButtonTriggered: SNMP.setMultiple( configuration )

    function updateConfig( field, value ) {
        let newConfig = ConfigManager.current
        configuration[ field ][ "value" ] = Wrappers.getFieldValue( configuration[ field ], value )
        newConfig[ "temperature" ] = configuration
        ConfigManager.current = newConfig
    }

    Connections
    {
        target: SNMP

        function onSettingsChanged()
        {
            configuration = ConfigManager.get()[ "temperature" ]
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
                _fields.push( configuration[ "stNumberTemperatureSensors" ] )

                let temperatureTherehold = configuration[ "stLowTemperatureTherehold" ]
                temperatureTherehold[ "wrapper" ] = Wrappers.divideByTen
                _fields.push( temperatureTherehold )


                let temperatureHight = configuration[ "stHightTemperatureTherehold" ]
                temperatureHight[ "wrapper" ] = Wrappers.divideByTen
                _fields.push( temperatureHight )

                let temperatureGisteresis = configuration[ "stTemperatureGisteresis" ]
                temperatureGisteresis[ "wrapper" ] = Wrappers.divideByTen
                _fields.push( temperatureGisteresis )

                return _fields
            }

            onFieldUpdated: ( field, value ) => {
                let newConfig = ConfigManager.current
                console.log( field, value )
                configuration[ field ][ "value" ] = value
                newConfig[ "temperature" ] = configuration
                ConfigManager.current = newConfig
            }
        }
    }
}
