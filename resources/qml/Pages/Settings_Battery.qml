import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import "../Components"
import "../Globals"
import "../wrappers.mjs" as Wrappers

Page
{
    property var configuration: ConfigManager.get()[ "battery" ]
    contentHeight: pageContent.implicitHeight + 20

    actionButtonIcon: "qrc:/images/icons/save.svg"
    actionButtonTitle: "Записать"

    onActionButtonTriggered: SNMP.setMultiple( configuration )

    function updateConfig( field, value ) {
        let newConfig = ConfigManager.current
        configuration[ field ][ "value" ] = Wrappers.getFieldValue( configuration[ field ], value )
        newConfig[ "battery" ] = configuration
        ConfigManager.current = newConfig
    }

    Connections
    {
        target: SNMP

        function onSettingsChanged()
        {
            configuration = ConfigManager.get()[ "battery" ]
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


        RowLayout {
            Layout.maximumWidth: 1200
            Layout.alignment: Qt.AlignHCenter| Qt.AlignTop
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: 10

            CardComponent {
                fields: {
                    let _fields = []

                    let floatVoltage = configuration[ "stFloatVoltage" ]
                    floatVoltage[ "wrapper" ] = Wrappers.divideByHundred
                    _fields.push( floatVoltage )

                    let eqVoltage = configuration[ "stEqualizeVoltage" ]
                    eqVoltage[ "wrapper" ] = Wrappers.divideByHundred
                    _fields.push( eqVoltage )

                    let lowVoltage = configuration[ "stCriticalLowVoltage" ]
                    lowVoltage[ "wrapper" ] = Wrappers.divideByHundred
                    _fields.push( lowVoltage )

                    let chargeLimit = configuration[ "stChargeCurrentLimit" ]
                    chargeLimit[ "wrapper" ] = Wrappers.divideByHundred
                    _fields.push( chargeLimit )

                    _fields.push( configuration[ "stEqualizeTime" ] )

                    return _fields
                }

                onFieldUpdated: ( field, value ) => updateConfig( field, value )
            }

            ColumnLayout {
                spacing: 10


                CardComponent {
                    fields: {
                        let _fields = []
                        let boostVoltage = configuration[ "stBoostVoltage" ]
                        boostVoltage[ "wrapper" ] = Wrappers.divideByHundred
                        _fields.push( boostVoltage )
                        _fields.push( configuration[ "stBoostEnable" ] )
                        _fields.push( configuration[ "stFastChTime" ] )
                        return _fields
                    }

                    onFieldUpdated: ( field, value ) => updateConfig( field, value )
                }

                CardComponent {
                    fields: {
                        let _fields = []

                        let termocompensation = configuration[ "stTermocompensationCoefficient" ]
                        termocompensation[ "wrapper" ] = Wrappers.divideByTen
                        _fields.push( termocompensation )

                        _fields.push( configuration[ "stTermocompensationEnable" ] )
                        return _fields
                    }

                    onFieldUpdated: ( field, value ) => updateConfig( field, value )
                }

                CardComponent {
                    fields: {
                        let _fields = []
                        _fields.push( configuration[ "stGroupCapacity" ] )
                        return _fields
                    }

                    onFieldUpdated: ( field, value ) => updateConfig( field, value )
                }

            }
        }
    }
}
