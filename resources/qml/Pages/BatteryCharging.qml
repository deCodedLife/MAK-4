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

    function addWrapper( config, wrapper ) {
        config[ "wrapper" ] = wrapper
        return config
    }

    actionButtonIcon: "qrc:/images/icons/save.svg"
    actionButtonTitle: "Экспортировать"

    onActionButtonTriggered: {
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
                tableOID: "psDischargeEntry"

                headers: [
                    TableHeaderM { title: "№ разряда"; expand: false },
                    TableHeaderM { title: "Время начала"; expand: false },
                    TableHeaderM { title: "Результат теста"; expand: false },
                    TableHeaderM { title: "Длительность\n(мин)"; expand: false },
                    TableHeaderM { title: "Емкость\nАч"; expand: false },
                    TableHeaderM { title: "Конечное\nнапряжение, В"; expand: false },
                    TableHeaderM { title: "группа1"; expand: false },
                    TableHeaderM { title: "группа2"; expand: false },
                    TableHeaderM { title: "группа3"; expand: false },
                    TableHeaderM { title: "группа4"; expand: false }
                ]

                rows: {
                    "psDischargeNumber": new Wrappers.RowItem(),
                    "psDischargeStartTime": new Wrappers.RowItem( Wrappers.RowTypes.TEXT, (value) =>
                    {
                        let dateTime = SNMP.dateToReadable( value ).split( " " )
                        return `${dateTime[0]}\n${dateTime[1]}`
                    }, "str" ),
                    "psDischargeResult": new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.parseErrors, "str" ),
                    "psDischargeLength": new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.secondsToMinutes ),
                    "psDischargeCapacity": new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.divideByThousand ),
                    "psDischargeFinalVoltage": new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.divideByHundred ),
                    "psDischargeGroup1": new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.parseErrors, "str" ),
                    "psDischargeGroup2": new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.parseErrors, "str" ),
                    "psDischargeGroup3": new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.parseErrors, "str" ),
                    "psDischargeGroup4": new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.parseErrors, "str" )
                }
            }

//            TableComponent {
//                Layout.alignment: Qt.AlignTop

//                headers: [
//                    { "title": "№ разряда", "expand": false },
//                    { "title": "Время начала", "expand": false },
//                    { "title": "Результат теста", "expand": false },
//                    { "title": "", "expand": false },
//                    { "title": "", "expand": false },
//                    { "title": "", "expand": false },
//                    { "title": "", "expand": false },
//                    { "title": "группа2", "expand": false },
//                    { "title": "группа3", "expand": false },
//                    { "title": "группа4", "expand": false },
//                ]

//                content: {
//                    let objects = SNMP.getBulk( "" )
//                    let fields = []
//                    let middle = objects.length / 14

//                    for ( let index = 0; index < middle; index++ ) {
//                        fields.push( addWrapper( { type: 5, value: objects[ middle * 5 + index ] }, value => {
//                            if ( parseInt(value) === 0 ) return "Подключено"
//                            if ( parseInt(value) === 1 ) return "Отключено"
//                            return value

//                        } ) )
//                        fields.push( addWrapper( { type: 5, value: objects[ middle * 6 + index ] }, value => {
//                            if ( parseInt(value) === 0 ) return "Подключено"
//                            if ( parseInt(value) === 1 ) return "Отключено"
//                            return value

//                        } ) )
//                        fields.push( addWrapper( { type: 5, value: objects[ middle * 7 + index ] }, value => {
//                            if ( parseInt(value) === 0 ) return "Подключено"
//                            if ( parseInt(value) === 1 ) return "Отключено"
//                            return value

//                        } ) )
//                        fields.push( addWrapper( { type: 5, value: objects[ middle * 8 + index ] }, value => {
//                            if ( parseInt(value) === 0 ) return "Подключено"
//                            if ( parseInt(value) === 1 ) return "Отключено"
//                            return value

//                        } ) )
//                    }
//                    return fields
//                }
//            }

        }
    }
}
