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

                Timer
                {
                    interval: ConfigManager.get()[ "main" ][ "updateDelay" ][ "value" ] * 1000
                    repeat: true
                    running: true
                    triggeredOnStart: true
                    onTriggered: SNMP.getOIDs( powerDefence.iconOID, [ powerDefence.iconOID + ".0" ] )
                }
                state: "null"

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
                    }

                ]

                Connections
                {
                    target: SNMP

                    function onGotRowsContent( root: string, data: object )
                    {
                        if ( root !== powerDefence.iconOID ) return
                        powerDefence.state = data[ powerDefence.iconOID ][ "num" ] === 0 ? "enabled" : "disabled"
                    }
                }
            }

        }
    }
}
