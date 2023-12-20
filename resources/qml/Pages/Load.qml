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

        ColumnLayout {

            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.maximumWidth: 1200
            spacing: 10

            TableComponent {
                Layout.alignment: Qt.AlignTop

                headers: [
                    { "title": "Напряжение нагрузки, В", "expand": true },
                    { "title": "Ток нагрузки, А", "expand": true },
                    { "title": "Состояние нагрузки", "expand": true }
                ]

                content: [
                    addWrapper( { type: 4, field: "psLoadVoltage" }, (value) => { return parseFloat( value ) / 100 } ),
                    addWrapper( { type: 4, field: "psLoadCurrent" }, (value) => { return parseFloat( value ) / 1000 } ),
                    addWrapper( { type: 4, field: "psLoadStatus" }, (value) => {
                        if ( parseInt(value) === 0 ) return "Норма"
                        if ( parseInt(value) === 1 ) return "Термокомпенсация"
                        if ( parseInt(value) === 2 ) return "Пониженное напряжение"
                        if ( parseInt(value) === 3 ) return "Повышенное напряжение"
                        if ( parseInt(value) === 4 ) return "Ошибка"
                        return value
                    } )
                ]

            }

            TableComponent {
                Layout.alignment: Qt.AlignTop

                headers: [
                    { "title": "№ АЗН", "expand": true },
                    { "title": "Состояние АЗН", "expand": true }
                ]

                content: {
                    let objects = SNMP.getBulk( "psLoadFuseEntry" )
                    let fields = []
                    let middle = objects.length / 2

                    for ( let index = 0; index < middle; index++ ) {
                        fields.push( { type: 5, value: objects[ index ] } )
                        fields.push( addWrapper( { type: 5, value: objects[ middle + index ] }, ( value ) => {
                            if ( parseInt(value) === 0 ) return "Включено"
                            if ( parseInt(value) === 1 ) return "Выключено"
                            if ( parseInt(value) === 2 ) return "Неизвестно"
                            if ( parseInt(value) === 3 ) return "Ошибка"
                            return value

                        } ) )
                    }
                    return fields
                }
            }

        }
    }
}
