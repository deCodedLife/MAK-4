import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import "../Components"
import "../Globals"
import "../wrappers.mjs" as Wrappers

Page
{
    property var configuration: ConfigManager.get()[ "tests" ]
    contentHeight: pageContent.implicitHeight + 20

    actionButtonIcon: "qrc:/images/icons/save.svg"
    actionButtonTitle: "Записать"

    onActionButtonTriggered: SNMP.setMultiple( configuration )

    function updateConfig( field, value ) {
        let newConfig = ConfigManager.current
        configuration[ field ][ "value" ] = Wrappers.getFieldValue( configuration[ field ], value )
        newConfig[ "tests" ] = configuration
        ConfigManager.current = newConfig
    }

    Connections
    {
        target: SNMP

        function onSettingsChanged()
        {
            configuration = ConfigManager.get()[ "tests" ]
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


        ColumnLayout {
            Layout.maximumWidth: 1200
            Layout.alignment: Qt.AlignHCenter| Qt.AlignTop
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: 10

            Text {
                text: "Стандартный тест"
                Layout.alignment: Qt.AlignHCenter
                font.pointSize: Globals.h4
            }

            RowLayout {
                spacing: 10

                CardComponent {
                    fields: {
                        let _fields = []

                        let floatVoltage = configuration[ "stEndTestVoltage" ]
                        floatVoltage[ "wrapper" ] = Wrappers.divideByHundred
                        _fields.push( floatVoltage )

                        _fields.push( configuration[ "stFixedLoadCurEnable" ] )
                        _fields.push( configuration[ "stFixedLoadCur" ] )
                        _fields.push( configuration[ "stDischCur" ] )

                        return _fields
                    }

                    onFieldUpdated: ( field, value ) => updateConfig( field, value )
                }

                CardComponent {
                    fields: {
                        let _fields = []

                        _fields.push( configuration[ "stPeriodTestEnable" ] )
                        _fields.push( configuration[ "stTestPeriod" ] )
                        _fields.push( configuration[ "stTestStartTime" ] )

                        return _fields
                    }

                    onFieldUpdated: ( field, value ) => updateConfig( field, value )
                }
            }

            Item { height: 20 }

            Text {
                text: "Короткий тест"
                Layout.alignment: Qt.AlignHCenter
                font.pointSize: Globals.h4
            }

            RowLayout {
                spacing: 10


                CardComponent {
                    fields: {
                        let _fields = []
                        let boostVoltage = configuration[ "stShortTestVoltage" ]
                        boostVoltage[ "wrapper" ] = Wrappers.divideByHundred
                        _fields.push( boostVoltage )
                        _fields.push( configuration[ "stShortTestTimer" ] )
                        return _fields
                    }

                    onFieldUpdated: ( field, value ) => updateConfig( field, value )
                }

                CardComponent {
                    fields: {
                        let _fields = []

                        _fields.push( configuration[ "stShortTestEnable" ] )
                        _fields.push( configuration[ "stShortTestPeriod" ] )
                        _fields.push( configuration[ "stShortTestStartTime" ] )
                        return _fields
                    }

                    onFieldUpdated: ( field, value ) => updateConfig( field, value )
                }

            }
        }
    }
}
