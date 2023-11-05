import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import "../Components"
import "../Globals"

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

            headers: [
                { "title": "№ Фазы", "expand": true },
                { "title": "Напряжение, В", "expand": true },
                { "title": "Состояние", "expand": true }
            ]

            content: {
                let objects = SNMP.getBulk( "psLineEntry" )
                let fields = []
                let middle = objects.length / 3

                for ( let index = 0; index < middle; index++ ) {
                    fields.push( { type: 5, value: objects[ index ] } )
                    fields.push( { type: 5, value: objects[ middle * 1 + index  ] } )
                    fields.push( addWrapper( { type: 5, value: objects[ middle * 2 + index  ] }, value => {
                        if ( parseInt( value ) === 0 ) return "Норма"
                        if ( parseInt( value ) === 1 ) return "Напряжение понижено"
                        if ( parseInt( value ) === 2 ) return "Напряжение повышено"
                        if ( parseInt( value ) === 3 ) return "Ошибка"
                        if ( parseInt( value ) === 4 ) return "Авария"
                        if ( parseInt( value ) === 5 ) return "Авария"
                        return value
                    } ) )
                }
                return fields
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

                state: "disabled"
                states: [
                    State {
                        name: "enabled"
                        PropertyChanges {
                            target: powerDefence
                            icon.source: "qrc:/images/icons/flash_on.svg"
                            icon.color: "F1DD23"
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

                Component.onCompleted: {
                    let state = SNMP.getOIDs( ["psLightProtStatus"] )
                    if ( parseInt( state ) !== 0 ) powerDefence.state = "disabled"
                    else powerDefence.state = "enabled"
                }
            }

        }
    }
}
