import QtQuick
import QtQuick.Layouts

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
                { "title": "№", "expand": false },
                { "title": "Входное\nнапряжение, В", "expand": true },
                { "title": "Выходное\nнапряжение, В", "expand": true },
                { "title": "Температура, °C", "expand": true },
                { "title": "Ток, А", "expand": true },
                { "title": "Состояние", "expand": false }
            ]

            content: {
                let objects = SNMP.getBulk( "psVbvEntry" )
                let fields = []
                let middle = objects.length / 7

                for ( let index = 0; index < middle; index++ ) {
                    fields.push( { type: 5, value: objects[ index ] } )
                    fields.push( { type: 5, value: parseFloat( parseInt( objects[ middle * 4 + index  ] ) / 100 ) } )
                    fields.push( { type: 5, value: objects[ middle * 1 + index  ] } )
                    fields.push( { type: 5, value: objects[ middle * 5 + index  ] } )
                    fields.push( { type: 5, value: parseFloat( parseInt( objects[ middle * 4 + index  ] ) / 1000 ) } )
                    fields.push( addWrapper( { type: 5, value: objects[ middle * 3 + index  ] }, value => {
                        if ( parseInt( value ) === 0 ) return "Норма"
                        if ( parseInt( value ) === 1 ) return "Авария"
                        if ( parseInt( value ) === 2 ) return "Авария сети"
                        if ( parseInt( value ) === 3 ) return "Перегрев"
                        if ( parseInt( value ) === 4 ) return "Перегрузка"
                        if ( parseInt( value ) === 5 ) return "Авария вентилятора"
                        if ( parseInt( value ) === 6 ) return "Авария вентилятора"
                        if ( parseInt( value ) === 7 ) return "Отключено"
                        if ( parseInt( value ) === 8 ) return "Неверный тип"
                        if ( parseInt( value ) === 9 ) return "Неизвестно"
                        if ( parseInt( value ) === 10 ) return "Отсутствует"
                        return value
                    } ) )
                }
                return fields
            }
        }
    }
}
