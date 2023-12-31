import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs

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

    FileDialog {
        id: fileDialog

        property list<string> headers
        property list<string> rows
        property string sep: ";"

        nameFilters: ["CSV table (*.csv)"]
        fileMode: FileDialog.SaveFile
        onAccepted: {
            let file = selectedFile.toString()
            if ( Qt.platform.os === "windows" ) file = file.split( "file:///" )[ 1 ]
            else file = file.split( "file://" )[ 1 ]
            SNMP.exportTable( file, headers, rows, sep )
        }
    }

    Dialog {
        id: messageDialog
        title: "Экспорт"
        visible: false

        anchors.centerIn: root.parent.parent
        parent: root.parent.parent
        width: 500

        ColumnLayout {
            anchors.fill: parent
            spacing: 10

            TextField {
                Layout.fillWidth: true
                id: rowsStart
                validator: IntValidator {
                    bottom: 1
                    top: bateryCharging.rowsCount - 1
                }
                placeholderText: "Начать со строки"
                text: "1"
                color: acceptableInput ? Globals.textColor : Globals.errorColor
            }

            TextField {
                Layout.fillWidth: true
                id: rowsEnd
                validator: IntValidator {
                    bottom: 1
                    top: bateryCharging.rowsCount
                }
                placeholderText: "Выгрузить до"
                color: acceptableInput ? Globals.textColor : Globals.errorColor
            }
        }

        onOpened: rowsEnd.text = bateryCharging.rowsCount

        onAccepted: {
            let headers = bateryCharging.headers.map( (header) => header.title.replace( "\n", " " ) )
            let rows = []
            let contentKeys = Object.keys( bateryCharging.content )
            let tableRowsCount = bateryCharging.rowsCount

            if ( !rowsStart.acceptableInput ) return
            if ( !rowsEnd.acceptableInput ) return

            let startFrom = parseInt( rowsStart.text ) - 1
            let endAt = parseInt( rowsEnd.text )

            if ( startFrom > endAt ) return

            for ( let row = startFrom; row < endAt; row++ ) {

                for( let index = 0; index < contentKeys.length; index++ ) {
                    let value = ""
                    if ( journalTable.content[ contentKeys[ index ] ][ row ].value )
                        value = journalTable.content[ contentKeys[ index ] ][ row ].value
                    else ""
                    let fieldValue = value.toString()
                    rows.push( fieldValue.replace( "\n", " " ) )
                }

            }

            fileDialog.headers = headers
            fileDialog.rows = rows
            fileDialog.open()
        }

        modal: false
        standardButtons: Dialog.Save
    }

    onActionButtonTriggered: {
        messageDialog.open()
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
                id: bateryCharging
                Layout.alignment: Qt.AlignTop
                tableOID: "psDischargeEntry"

                headers: [
                    TableHeaderM { title: "№ разряда"; expand: false },
                    TableHeaderM { title: "Время начала"; expand: false },
                    TableHeaderM { title: "Результат"; expand: false },
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
                    "psDischargeLength": new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.toTime ),
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
