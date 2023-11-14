import QtQuick
import QtQuick.Layouts

import "../Components"
import "../Globals"

Page
{
    id: root
    contentHeight: content.implicitHeight + 20

    function addWrapper( config, wrapper ) {
        config[ "wrapper" ] = wrapper
        return config
    }

    property list<var> tables: []
    property list<var> headers: [
        { "title": "Параметр", "expand": false },
        { "title": "Значение", "expand": false },
    ]

    Component.onCompleted: {
        let objects = SNMP.getBulk( "psBMSEntry" )
        let fields = []
        let middle = 4

        for ( let index = 0; index < middle; index++ ) {
            let table = []
            table.push( { type: 5, value: "Напряжение, В" } )
            table.push( { type: 5, value: parseFloat( parseInt( objects[ middle * 1 + index  ] ) / 100 ) } )
            table.push( { type: 5, value: "Ток, А" } )
            table.push( { type: 5, value: parseFloat( parseInt( objects[ middle * 2 + index  ] ) / 100 ) } )
            table.push( { type: 5, value: "Статус" } )
            table.push( addWrapper( { type: 5, value: objects[ middle * 3 + index  ] }, value => {
                if ( parseInt( value ) === 0 ) return "Норма"
                if ( parseInt( value ) === 1 ) return "Авария"
                if ( parseInt( value ) === 2 ) return "Отключено"
                return value
            } ) )
            table.push( { type: 5, value: "Состояние" } )
            table.push( addWrapper( { type: 5, value: objects[ middle * 4 + index  ] }, value => {
                if ( parseInt( value ) === 0 ) return "Поддержка"
                if ( parseInt( value ) === 1 ) return "Заряд"
                if ( parseInt( value ) === 2 ) return "Разряд"
                return value
            } ) )
            table.push( { type: 5, value: "Температура 1, °C" } )
            table.push( { type: 5, value: parseInt( objects[ middle * 5 + index  ] ) } )
            table.push( { type: 5, value: "Температура 2, °C" } )
            table.push( { type: 5, value: parseInt( objects[ middle * 6 + index  ] ) } )

            table.push( { type: 5, value: "Емкость, Ач" } )
            table.push( { type: 5, value: parseFloat( parseInt( objects[ middle * 7 + index  ] ) / 100 ) } )
            table.push( { type: 5, value: "Оставшаяся\nЕмкость Ач" } )
            table.push( { type: 5, value: parseFloat( parseInt( objects[ middle * 8 + index  ] ) / 100 ) } )
            table.push( { type: 5, value: "Циклы" } )
            table.push( { type: 5, value: objects[ middle * 9 + index  ] } )
            table.push( { type: 5, value: "Количество ячеек" } )
            table.push( { type: 5, value: objects[ middle * 10 + index  ] } )
            table.push( { type: 5, value: "MIN напряжение, В" } )
            table.push( { type: 5, value: parseFloat( parseInt( objects[ middle * 11 + index  ] ) / 1000 ) } )
            table.push( { type: 5, value: "MAX напряжение, В" } )
            table.push( { type: 5, value: parseFloat( parseInt( objects[ middle * 12 + index  ] ) / 1000 ) } )
            table.push( { type: 5, value: "MIN-MAX\nнапряжение, В" } )
            table.push( { type: 5, value: parseFloat( parseInt( objects[ middle * 13 + index  ] ) / 1000 ) } )


            for ( let cell = 14; cell < 30; cell++ ) {
                table.push( { type: 5, value: `Ячейка ${cell - 13}, В` } )
                table.push( { type: 5, value: parseFloat( parseInt( objects[ middle * cell + index  ] ) / 1000 ) } )
            }

            tables.push( table )
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

                model: 4

                TableComponent {
                    Layout.alignment: Qt.AlignTop
                    header: "BMS" + (index + 1)

                    headers: root.headers
                    content: tables[ index ]
                }
            }
        }
    }
}
