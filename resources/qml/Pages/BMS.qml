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
        { "title": "BMS №", "expand": false },
        { "title": "Напряжение, В", "expand": false },
        { "title": "Ток, А", "expand": false },
        { "title": "Статус", "expand": false },
        { "title": "Состояние", "expand": true },
        { "title": "Температура 1, °C", "expand": false },
        { "title": "Температура 2, °C", "expand": false },
        { "title": "Емкость, Ач", "expand": false },
        { "title": "Оставшаяся\nЕмкость Ач", "expand": false },
        { "title": "Циклы", "expand": false },
        { "title": "Количество ячеек", "expand": false },
        { "title": "MIN напряжение, В", "expand": false },
        { "title": "MAX напряжение, В", "expand": false },
        { "title": "MIN-MAX\nнапряжение, В", "expand": false },
        { "title": "Ячейка 1, В", "expand": false },
        { "title": "Ячейка 2, В", "expand": false },
        { "title": "Ячейка 3, В", "expand": false },
        { "title": "Ячейка 4, В", "expand": false },
        { "title": "Ячейка 5, В", "expand": false },
        { "title": "Ячейка 6, В", "expand": false },
        { "title": "Ячейка 7, В", "expand": false },
        { "title": "Ячейка 8, В", "expand": false },
        { "title": "Ячейка 9, В", "expand": false },
        { "title": "Ячейка 10, В", "expand": false },
        { "title": "Ячейка 11, В", "expand": false },
        { "title": "Ячейка 12, В", "expand": false },
        { "title": "Ячейка 13, В", "expand": false },
        { "title": "Ячейка 14, В", "expand": false },
        { "title": "Ячейка 15, В", "expand": false },
        { "title": "Ячейка 16, В", "expand": false },
    ]

    Component.onCompleted: {
        let objects = SNMP.getBulk( "psBMSEntry" )
        let fields = []
        let middle = objects.length / 30
        let maxBMS = 4

        for ( let index = 0; index < middle; index++ ) {
            if ( index > maxBMS ) continue
            let table = []

            table.push( { type: 5, value: objects[ index ] } )
            table.push( { type: 5, value: parseFloat( parseInt( objects[ middle * 1 + index  ] ) / 100 ) } )
            table.push( { type: 5, value: parseFloat( parseInt( objects[ middle * 2 + index  ] ) / 100 ) } )
            table.push( addWrapper( { type: 5, value: objects[ middle * 3 + index  ] }, value => {
                if ( parseInt( value ) === 0 ) return "Норма"
                if ( parseInt( value ) === 1 ) return "Авария"
                if ( parseInt( value ) === 2 ) return "Отключено"
                return value
            } ) )
            table.push( addWrapper( { type: 5, value: objects[ middle * 4 + index  ] }, value => {
                if ( parseInt( value ) === 0 ) return "Поддержка"
                if ( parseInt( value ) === 1 ) return "Заряд"
                if ( parseInt( value ) === 2 ) return "Разряд"
                return value
            } ) )
            table.push( { type: 5, value: parseFloat( parseInt( objects[ middle * 5 + index  ] ) / 10 ) } )
            table.push( { type: 5, value: parseFloat( parseInt( objects[ middle * 6 + index  ] ) / 10 ) } )
            table.push( { type: 5, value: parseFloat( parseInt( objects[ middle * 7 + index  ] ) / 100 ) } )
            table.push( { type: 5, value: parseFloat( parseInt( objects[ middle * 8 + index  ] ) / 100 ) } )
            table.push( { type: 5, value: objects[ middle * 9 + index  ] } )
            table.push( { type: 5, value: objects[ middle * 10 + index  ] } )
            table.push( { type: 5, value: parseFloat( parseInt( objects[ middle * 11 + index  ] ) / 1000 ) } )
            table.push( { type: 5, value: parseFloat( parseInt( objects[ middle * 12 + index  ] ) / 1000 ) } )
            table.push( { type: 5, value: parseFloat( parseInt( objects[ middle * 13 + index  ] ) / 1000 ) } )

            table.push( { type: 5, value: parseFloat( parseInt( objects[ middle * 14 + index  ] ) / 1000 ) } )
            table.push( { type: 5, value: parseFloat( parseInt( objects[ middle * 15 + index  ] ) / 1000 ) } )
            table.push( { type: 5, value: parseFloat( parseInt( objects[ middle * 16 + index  ] ) / 1000 ) } )
            table.push( { type: 5, value: parseFloat( parseInt( objects[ middle * 17 + index  ] ) / 1000 ) } )
            table.push( { type: 5, value: parseFloat( parseInt( objects[ middle * 18 + index  ] ) / 1000 ) } )
            table.push( { type: 5, value: parseFloat( parseInt( objects[ middle * 19 + index  ] ) / 1000 ) } )
            table.push( { type: 5, value: parseFloat( parseInt( objects[ middle * 20 + index  ] ) / 1000 ) } )
            table.push( { type: 5, value: parseFloat( parseInt( objects[ middle * 21 + index  ] ) / 1000 ) } )
            table.push( { type: 5, value: parseFloat( parseInt( objects[ middle * 22 + index  ] ) / 1000 ) } )
            table.push( { type: 5, value: parseFloat( parseInt( objects[ middle * 23 + index  ] ) / 1000 ) } )
            table.push( { type: 5, value: parseFloat( parseInt( objects[ middle * 24 + index  ] ) / 1000 ) } )
            table.push( { type: 5, value: parseFloat( parseInt( objects[ middle * 25 + index  ] ) / 1000 ) } )
            table.push( { type: 5, value: parseFloat( parseInt( objects[ middle * 26 + index  ] ) / 1000 ) } )
            table.push( { type: 5, value: parseFloat( parseInt( objects[ middle * 27 + index  ] ) / 1000 ) } )
            table.push( { type: 5, value: parseFloat( parseInt( objects[ middle * 28 + index  ] ) / 1000 ) } )
            table.push( { type: 5, value: parseFloat( parseInt( objects[ middle * 29 + index  ] ) / 1000 ) } )

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

        Repeater {

            model: tables

            TableComponent {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                Layout.maximumWidth: 1200

                headers: root.headers
                content: tables[ index ]
            }

        }
    }
}
