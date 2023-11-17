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
        }
    }
}
