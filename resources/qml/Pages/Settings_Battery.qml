import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import "../Components"
import "../Globals"

Page
{
    property var configuration: ConfigManager.get()[ "battery" ]

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
            Layout.alignment: Qt.AlignHCenter| Qt.AlignTop
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: 10

            CardComponent {
                fields: [
                    configuration[ `stFloatVoltage` ],
                    configuration[ `stEqualizeVoltage` ],
                    configuration[ `stCriticalLowVoltage` ],
                    configuration[ `stChargeCurrentLimit` ],
                    configuration[ `stEqualizeTime` ]
                ]

                onFieldUpdated: ( field, value ) => {
                    let newConfig = ConfigManager.current
                    configuration[ field ][ "value" ] = value
                    newConfig[ "battery" ] = configuration
                    ConfigManager.current = newConfig
                }
            }

            ColumnLayout {
                spacing: 10


                CardComponent {
                    fields: [
                        configuration[ `stBoostVoltage` ],
                        configuration[ `stBoostEnable` ]
                    ]

                    onFieldUpdated: ( field, value ) => {
                        let newConfig = ConfigManager.current
                        configuration[ field ][ "value" ] = value
                        newConfig[ "battery" ] = configuration
                        ConfigManager.current = newConfig
                    }
                }

                CardComponent {
                    fields: [
                        configuration[ `stTermocompensationCoefficient` ],
                        configuration[ `stTermocompensationEnable` ]
                    ]

                    onFieldUpdated: ( field, value ) => {
                        let newConfig = ConfigManager.current
                        configuration[ field ][ "value" ] = value
                        newConfig[ "battery" ] = configuration
                        ConfigManager.current = newConfig
                    }
                }

                CardComponent {
                    fields: [
                        configuration[ `stEndTestVoltage` ],
                        configuration[ `stGroupCapacity` ],
                    ]

                    onFieldUpdated: ( field, value ) => {
                        let newConfig = ConfigManager.current
                        configuration[ field ][ "value" ] = value
                        newConfig[ "battery" ] = configuration
                        ConfigManager.current = newConfig
                    }
                }

            }
        }
    }
}
