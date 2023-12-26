import QtQuick
import QtQuick.Layouts

import "../Components"
import "../Globals"
import "../Models"

import "../wrappers.mjs" as Wrappers

Page
{
    id: root

    contentHeight: content.implicitHeight + 20
    property string buttonOID: "psTestControl"

    function addWrapper( config, wrapper ) {
        config[ "wrapper" ] = wrapper
        return config
    }

    state: {
        SNMP.getOIDs( buttonOID, [ buttonOID + ".0" ] )
        return "null"
    }

    Connections
    {
        target: SNMP

        function onGotRowsContent( root: string, data: object )
        {
            if ( root !== buttonOID ) return
            state = data[ buttonOID ][ "num" ] === 1 ? "started" : "stopped"
        }
    }

    states: [
        State {
            name: "stopped"
            PropertyChanges {
                target: root
                actionButtonIcon: "qrc:/images/icons/start.svg"
                actionButtonTitle: "Начать тест"
            }
        },
        State {
            name: "started"
            PropertyChanges {
                target: root
                actionButtonIcon: "qrc:/images/icons/stop.svg"
                actionButtonTitle: "Закончить тест"
            }
        }
    ]

    onActionButtonTriggered: {
        if ( state === "stopped" ) {
            state = "started"
            SNMP.setOID( buttonOID, 1 )
            return
        }
        SNMP.setOID( buttonOID, 0 )
        state = "stopped"
    }

    ColumnLayout {
        id: content

        anchors.fill: parent
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        anchors.leftMargin: 20
        anchors.rightMargin: 20

        ColumnLayout {

            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.maximumWidth: 1200
            spacing: 10

            TableComponent {
                Layout.alignment: Qt.AlignTop

                tableOID: "psTestEntry"

                headers: [
                    TableHeaderM { title: "№ Теста"; expand: false },
                    TableHeaderM { title: "Время начала"; expand: false },
                    TableHeaderM { title: "Результат"; expand: false },
                    TableHeaderM { title: "Длительность\n(мин)"; expand: false },
                    TableHeaderM { title: "Емкость\nАч"; expand: false },
                    TableHeaderM { title: "Конечное\nнапряжение, В"; expand: false },
                    TableHeaderM { title: "группа1"; expand: false },
                    TableHeaderM { title: "группа2"; expand: false },
                    TableHeaderM { title: "группа3"; expand: false },
                    TableHeaderM { title: "группа4"; expand: false }
                ]

                rows: {
                    "psTestNumber": new Wrappers.RowItem(),
                    "psTestStartTime": new Wrappers.RowItem( Wrappers.RowTypes.TEXT, (value) =>
                    {
                        let dateTime = SNMP.dateToReadable( value ).split( " " )
                        return `${dateTime[0]}\n${dateTime[1]}`
                    }, "str" ),
                    "psTestResult": new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.parseErrors, "str" ),
                    "psTestLength": new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.toTime ),
                    "psTestCapacity": new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.divideByThousand ),
                    "psTestFinalVoltage": new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.divideByHundred ),
                    "psTestGroup1": new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.parseErrors, "str" ),
                    "psTestGroup2": new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.parseErrors, "str" ),
                    "psTestGroup3": new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.parseErrors, "str" ),
                    "psTestGroup4": new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.parseErrors, "str" )
                }
            }
        }
    }
}
