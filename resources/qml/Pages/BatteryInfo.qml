import QtQuick
import QtQuick.Layouts

import "../Components"
import "../Globals"
import "../Models"

import "../wrappers.mjs" as Wrappers

Page
{
    id: root
    contentHeight: content.implicitHeight
    property string buttonOID: "psEqChargeControl"

    function addWrapper( config, wrapper ) {
        config[ "wrapper" ] = wrapper
        return config
    }

    state: {
        SNMP.getOIDs( buttonOID, [ buttonOID ] )
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
                actionButtonTitle: "Начать ВЗ"
            }
        },
        State {
            name: "started"
            PropertyChanges {
                target: root
                actionButtonIcon: "qrc:/images/icons/stop.svg"
                actionButtonTitle: "Закончить ВЗ"
            }
        }
    ]

    onActionButtonTriggered: {
        if ( state === "stopped" ) {
            state = "started"
            SNMP.setOID( buttonOID, 1 )
            return
        }
        SNMP.setOID( buttonOID, 2 )
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

            FieldsTable {
                Layout.alignment: Qt.AlignTop

                headers: [
                    TableHeaderM { title: "Суммарный ток батареи, А"; expand: true },
                    TableHeaderM { title: "Состояние батареи"; expand: true }
                ]

                fields: [
                    new Wrappers.ContentItem( "psBatterySummCurrent", "", Wrappers.RowTypes.TEXT, "num", Wrappers.divideByThousand ),
                    new Wrappers.ContentItem( "psBatteryStatus", "", Wrappers.RowTypes.TEXT, "str", Wrappers.parseErrors ),
                ]
            }

            TableComponent {
                Layout.alignment: Qt.AlignTop
                tableOID: "psGroupEntry"

                headers: [
                    TableHeaderM { title: "№ группы"; expand: true },
                    TableHeaderM { title: "Напряжение, В"; expand: true },
                    TableHeaderM { title: "Ток, А"; expand: true },
                    TableHeaderM { title: "Состояние группы"; expand: true },
                    TableHeaderM { title: "Состояние аппарата защиты"; expand: true }
                ]

                rows: {
                    "psGroupNumber": new Wrappers.RowItem(),
                    "psGroupCurrent": new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.divideByThousand ),
                    "psGroupVoltage": new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.divideByHundred ),
                    "psGroupFuseStatus": new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.parseErrors, "str" ),
                    "psGroupStatus": new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.parseErrors, "str" )
                }
            }

        }
    }
}
