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

    property string columnOID: "psBMSNumber"
    property string tableName: "psBMSEntry"
    property int tablesCount: 0

    Timer
    {
        interval: Math.max( ConfigManager.get()[ "main" ][ "updateDelay" ][ "value" ] * 1000, 10000 )
        triggeredOnStart: true
        running: true
        repeat: true
        onTriggered: {
            SNMP.getTable( columnOID )
            SNMP.getTable( tableName )
        }
    }

    Connections
    {
        target: SNMP

        function onGotRowsContent( root: string, data: object )
        {
            if ( root !== columnOID ) return
            tablesCount = Object.keys( data[ columnOID ] ).length
        }
    }

    ColumnLayout {
        id: content

        anchors.fill: parent
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        anchors.leftMargin: 20
        anchors.rightMargin: 20

        GridLayout {
            id: grid

            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.maximumWidth: 1200
            rowSpacing: 10
            columnSpacing: 10
            width: content.width
            height: contentHeight

            rows: 1
            columns: 4

            onWidthChanged: calcRows()

            function calcRows() {
                grid.rows = width >= 1000 ? 2 : 1
                grid.columns = width >= 1000 ? 4 : 2
            }

            Component.onCompleted: calcRows()

            Repeater {
                id: repeater
                model: tablesCount

                TableComponent {
                    Layout.alignment: Qt.AlignTop
                    header: "BMS" + (index + 1)
                    tableOID: "psBMSEntry"
                    reversed: true
                    external: true
                    column: index + 1

                    headers: [
                        TableHeaderM { title: "Параметр"; expand: false },
                        TableHeaderM { title: "Значение"; expand: false }
                    ]

                    rows: {
                        let rows = {}

                        rows[ "psBMSVoltage"] = new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.divideByHundred, "num", "Напряжение, В" )
                        rows[ "psBMSCurrent"] = new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.divideByHundred, "num", "Ток, А" )
                        rows[ "psBMSStatus"] = new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.parseErrors, "str", "Статус" )
                        rows[ "psBMSSubStatus"] = new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.parseErrors, "str", "Состояние" )
                        rows[ "psBMSIntTemperature"] = new Wrappers.RowItem( Wrappers.RowTypes.TEXT, (v) => v, "num", "Температура 1, °C" )
                        rows[ "psBMSExtTemperature"] = new Wrappers.RowItem( Wrappers.RowTypes.TEXT, (v) => v, "num", "Температура 2, °C" )
                        rows[ "psBMSCap"] = new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.divideByHundred, "num", "Емкость, Ач" )
                        rows[ "psBMSRemainCap"] = new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.divideByHundred, "num", "Оставшаяся\nЕмкость Ач" )
                        rows[ "psBMSCycles"] = new Wrappers.RowItem( Wrappers.RowTypes.TEXT, (v) => v, "num", "Циклы" )
                        rows[ "psBMSCells"] = new Wrappers.RowItem( Wrappers.RowTypes.TEXT, (v) => v, "num", "Количество ячеек" )
                        rows[ "psBMSCellVoltMin"] = new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.divideByThousand, "num", "MIN напряжение, В" )
                        rows[ "psBMSCellVoltMax"] = new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.divideByThousand, "num", "MAX напряжение, В" )
                        rows[ "psBMSCellVoltDiff"] = new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.divideByThousand, "num", "MIN-MAX\nнапряжение, В" )

                        for ( let cell = 14; cell < 30; cell++ )
                            rows[ `psBMSCell${cell - 13}Voltage` ] = new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.divideByThousand, "num", `Ячейка${cell - 13}, B` )

                        return rows
                    }
                }
            }
        }
    }
}
