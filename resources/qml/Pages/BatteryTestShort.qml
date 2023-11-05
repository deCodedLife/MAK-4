import QtQuick
import QtQuick.Layouts

import "../Components"
import "../Globals"

Page
{
    id: root
    contentHeight: content.implicitHeight

    function addWrapper( config, wrapper ) {
        config[ "wrapper" ] = wrapper
        return config
    }

    state: {
        let oid = SNMP.getOIDs( [ "psShortTestControl" ] )
        if ( parseInt( oid ) === 1 ) return "started"
        else return "stopped"
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
            SNMP.setOID( "psShortTestControl", 1 )
            return
        }
        SNMP.setOID( "psShortTestControl", 2 )
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

                headers: [
                    { "title": "№ разряда", "expand": false },
                    { "title": "Время теста", "expand": false },
                    { "title": "Результат теста", "expand": false },
                    { "title": "Длительность\n(мин)", "expand": false },
                    { "title": "Емкость\nАч", "expand": false },
                    { "title": "Конечное\nнапряжение, В", "expand": false },
                    { "title": "группа1", "expand": false },
                    { "title": "группа2", "expand": false },
                    { "title": "группа3", "expand": false },
                    { "title": "группа4", "expand": false },
                ]

                content: {
                    let objects = SNMP.getBulk( "psShortTestEntry" )
                    let fields = []
                    let middle = objects.length / 14

                    for ( let index = 0; index < middle; index++ ) {
                        fields.push( { type: 5, value: objects[ index ] } )
                        fields.push( addWrapper( { type: 5, value: objects[ middle * 1 + index ] }, value => {
                            let dateTime = SNMP.dateToReadable( value ).split( " " )
                            return `${dateTime[0]}\n${dateTime[1]}`
                        } ) )
                        fields.push( addWrapper( { type: 5, value: objects[ middle * 2 + index ] }, value => {
                            if ( parseInt( value ) === 0 ) return "Успешно"
                            if ( parseInt( value ) === 1 ) return "Неизвестно"
                            if ( parseInt( value ) === 2 ) return "Остановлено"
                            if ( parseInt( value ) === 3 ) return "Низкий ток"
                            if ( parseInt( value ) === 4 ) return "Идёт заряд"
                            if ( parseInt( value ) === 5 ) return "Батарея выкл"
                            if ( parseInt( value ) === 6 ) return "Таймаут"
                            if ( parseInt( value ) === 7 ) return "Ошибка измерения"
                            if ( parseInt( value ) === 8 ) return "Пусто"
                            if ( parseInt( value ) === 9 ) return "Ошибка"
                            return value
                        } ) )
                        fields.push( { type: 5, value: parseFloat( parseInt(objects[ middle * 3 + index ]) / 60 ).toFixed(2) } )
                        fields.push( { type: 5, value: (parseFloat( objects[ middle * 3 + index ] ) / 1000) } )
                        fields.push( { type: 5, value: (parseFloat( objects[ middle * 4 + index ] ) / 100) } )
                        fields.push( addWrapper( { type: 5, value: objects[ middle * 5 + index ] }, value => {
                            if ( parseInt(value) === 0 ) return "Подключено"
                            if ( parseInt(value) === 1 ) return "Отключено"
                            return value

                        } ) )
                        fields.push( addWrapper( { type: 5, value: objects[ middle * 6 + index ] }, value => {
                            if ( parseInt(value) === 0 ) return "Подключено"
                            if ( parseInt(value) === 1 ) return "Отключено"
                            return value

                        } ) )
                        fields.push( addWrapper( { type: 5, value: objects[ middle * 7 + index ] }, value => {
                            if ( parseInt(value) === 0 ) return "Подключено"
                            if ( parseInt(value) === 1 ) return "Отключено"
                            return value

                        } ) )
                        fields.push( addWrapper( { type: 5, value: objects[ middle * 8 + index ] }, value => {
                            if ( parseInt(value) === 0 ) return "Подключено"
                            if ( parseInt(value) === 1 ) return "Отключено"
                            return value

                        } ) )
                    }
                    return fields
                }
            }

        }
    }
}
