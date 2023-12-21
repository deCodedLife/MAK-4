import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import "../Components"
import "../Globals"
import "../Models"

import "../wrappers.mjs" as Wrappers

Page
{
    contentHeight: content.implicitHeight + 20

    function addWrapper( config, wrapper ) {
        config[ "wrapper" ] = wrapper
        return config
    }

    ColumnLayout {
        id: content

        anchors.fill: parent
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        anchors.leftMargin: 20
        anchors.rightMargin: 20

        TableComponent {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.maximumWidth: 1200
            tableOID: "psLineEntry"

            headers: [
                TableHeaderM {
                    title: "№ Фазы"
                    expand: true
                },
                TableHeaderM {
                    title: "Напряжение, В"
                    expand: true
                },
                TableHeaderM {
                    title: "Состояние"
                    expand: true
                }
            ]

            rows: {
                "psLineNumber": new Wrappers.RowItem(),
                "psLineVoltage": new Wrappers.RowItem(),
                "psLineStatus": new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.parseErrors, "str" ),
            }
        }

        Item {

            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.maximumWidth: 1200
            Layout.fillWidth: true

            IconLabel {
                id: powerDefence
                color: Globals.textColor
                Layout.alignment: Qt.AlignLeft

                property string iconOID: "psLightProtStatus"

<<<<<<< HEAD
                Timer
                {
                    interval: ConfigManager.get()[ "main" ][ "updateDelay" ][ "value" ] * 1000
                    repeat: true
                    running: true
                    triggeredOnStart: true
                    onTriggered: SNMP.getOIDs( powerDefence.iconOID, [ powerDefence.iconOID + ".0" ] )
                }
                state: "null"
=======
                state: {
                    SNMP.getOIDs( iconOID, [ iconOID + ".0" ] )
                    return "null"
                }
>>>>>>> 67ebf0440430a1b1d2c539f15a23dad86d45bc01

                states: [
                    State {
                        name: "enabled"
                        PropertyChanges {
                            target: powerDefence
                            icon.source: "qrc:/images/icons/flash_on.svg"
                            icon.color: Globals.yellow
                            text: "Грозозащита: Норма"
                        }
                    },
                    State {
                        name: "disabled"
                        PropertyChanges {
                            target: powerDefence
                            icon.source: "qrc:/images/icons/flash_off.svg"
                            icon.color: Globals.textColor
                            text: "Грозозащита: Авария"
                        }
<<<<<<< HEAD
                    },
                    State {
                        name: "not_used"
                        PropertyChanges {
                            target: powerDefence
                            icon.source: "qrc:/images/icons/flash_off.svg"
                            icon.color: Globals.textColor
                            text: "Грозозащита: Не используется"
                        }
=======
>>>>>>> 67ebf0440430a1b1d2c539f15a23dad86d45bc01
                    }

                ]

                Connections
                {
                    target: SNMP

                    function onGotRowsContent( root: string, data: object )
                    {
                        if ( root !== powerDefence.iconOID ) return
<<<<<<< HEAD
                        let powerDef = powerDefence.state = data[ powerDefence.iconOID ][ "num" ]
                        if ( powerDef === 0 ) {
                            powerDefence.state = "enabled"
                            return
                        }
                        if ( powerDef !== 3 ) {
                            powerDefence.state = "disabled"
                            return
                        }
                        powerDefence.state = "not_used"
=======
                        powerDefence.state = data[ powerDefence.iconOID ][ "num" ] === 1 ? "enabled" : "disabled"
>>>>>>> 67ebf0440430a1b1d2c539f15a23dad86d45bc01
                    }
                }
            }

        }
    }
}
