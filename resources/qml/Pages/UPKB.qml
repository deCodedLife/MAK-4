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

    property string columnOID: "psBlockGroup.1"
    property string tableName: "PSBlockEntry"
    property int tablesCount: 0

    Timer
    {
        interval: 20 * 1000
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
            console.log( JSON.stringify( data ) )
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
            columns: tablesCount

            onWidthChanged: calcRows()

            function calcRows() {
                grid.rows = width >= 1000 ? 2 : 1
                grid.columns = width >= 1000 ? tablesCount : 2
            }

            Component.onCompleted: calcRows()

            Repeater {

                model: tablesCount

                TableComponent {
                    Layout.alignment: Qt.AlignTop
                    header: "УПКБ" + (index + 1)
                    tableOID: "PSBlockEntry"
                    reversed: true
                    external: true
                    column: index + 1

                    headers: [
                        TableHeaderM { title: "Номер"; expand: false },
                        TableHeaderM { title: "U, В"; expand: false },
                        TableHeaderM { title: "t, °C"; expand: false },
                        TableHeaderM { title: "Состояние"; expand: false }
                    ]

                    rows: {
                        "psBlockNumber": new Wrappers.RowItem( Wrappers.RowTypes.TEXT ),
                        "psBlockVoltage": new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.divideByHundred, "num" ),
                        "psBlockTemperature": new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.divideByHundred, "num" ),
                        "psBlockStatus": new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.parseErrors, "str" )
                    }
                }
            }
        }
    }
}
