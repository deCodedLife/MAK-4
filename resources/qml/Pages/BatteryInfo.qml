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
        let oid = SNMP.getOIDs( [ "psEqChargeControl" ] )
        if ( parseInt( oid ) === 1 ) return "started"
        else return "stopped"
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
            SNMP.setOID( "psEqChargeControl", 1 )
            return
        }
        SNMP.setOID( "psEqChargeControl", 2 )
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
                    { "title": "Суммарный ток батареи, А", "expand": true },
                    { "title": "Состояние батареи", "expand": true },
                ]

                content: [
                    addWrapper( { type: 4, field: "psBatterySummCurrent" }, value => { return parseFloat( value ) / 1000 } ),
                    addWrapper( { type: 4, field: "psBatteryStatus" }, value => {
                        if ( parseInt(value) === 0 ) return "Заряжается"
                        if ( parseInt(value) === 1 ) return "Плавает"
                        if ( parseInt(value) === 2 ) return "Быстрая зарядка"
                        if ( parseInt(value) === 3 ) return "Зарядка эквалайзер"
                        if ( parseInt(value) === 4 ) return "разрядка"
                        if ( parseInt(value) === 5 ) return "Низкий заряд"
                        if ( parseInt(value) === 6 ) return "Тестирование"
                        if ( parseInt(value) === 7 ) return "Отсутствует"
                        if ( parseInt(value) === 8 ) return "Ошибка"
                        return value
                    } )
                ]

            }

            TableComponent {
                Layout.alignment: Qt.AlignTop

                headers: [
                    { "title": "№ группы", "expand": true },
                    { "title": "Напряжение, В", "expand": true },
                    { "title": "Ток, А", "expand": true },
                    { "title": "Состояние группы", "expand": true },
                    { "title": "Состояние аппарата защиты", "expand": true }
                ]

                content: {
                    let objects = SNMP.getBulk( "psGroupEntry" )
                    let fields = []
                    let middle = objects.length / 5

                    for ( let index = 0; index < middle; index++ ) {
                        fields.push( { type: 5, value: objects[ index ] } )
                        fields.push( addWrapper( { type: 5, value: objects[ index * middle + 1 ] }, value => parseFloat( value ) / 100 ) )
                        fields.push( addWrapper( { type: 5, value: objects[ index * middle + 2 ] }, value => parseFloat( value ) / 1000 ) )
                        fields.push( addWrapper( { type: 5, value: objects[ index * middle + 3 ] }, value => {
                            if ( parseInt(value) === 0 ) return "Подключено"
                            if ( parseInt(value) === 1 ) return "Отключено"
                            if ( parseInt(value) === 2 ) return "Ошибка"
                            return value

                        } ) )
                        fields.push( addWrapper( { type: 5, value: objects[ index * middle + 4 ] }, value => {
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
