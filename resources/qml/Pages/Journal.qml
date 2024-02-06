import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Dialogs

import "../Components"
import "../Globals"
import "../Models"
import "../wrappers.mjs" as Wrappers


Page
{
    id: root
    contentHeight: content.implicitHeight + 20

    function addWrapper( config, wrapper ) {
        config[ "wrapper" ] = wrapper
        return config
    }

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
                    top: journalTable.rowsCount - 1
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
                    top: journalTable.rowsCount
                }
                placeholderText: "Выгрузить до"
                color: acceptableInput ? Globals.textColor : Globals.errorColor
            }
        }

        onOpened: rowsEnd.text = journalTable.rowsCount

        onAccepted: {
            let headers = journalTable.headers.map( (header) => header.title.replace( "\n", " " ) )
            let rows = []
            let contentKeys = Object.keys( journalTable.content )
            let tableRowsCount = journalTable.rowsCount

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

    ColumnLayout {
        id: content

        anchors.fill: parent
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        anchors.leftMargin: 20
        anchors.rightMargin: 20

        JournalTable {
            id: journalTable
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.maximumWidth: 1200
            tableOID: "psJournalEntry"
            rowsLength: width == 1200 ? 25 : 18

            footer: `Текущая страница: ${journalTable.currentPage}`

            headers: [
                TableHeaderM { title: "Номер события"; expand: true },
                TableHeaderM { title: "Время события UTC"; expand: true },
                TableHeaderM { title: "Тип события"; expand: true },
                TableHeaderM { title: "Событие"; expand: true }
            ]

            rows: {
                "psJournalNumber": new Wrappers.RowItem( Wrappers.RowTypes.TEXT, v => {return v}, "num" ),
                "psJournalTime": new Wrappers.RowItem( Wrappers.RowTypes.TEXT, (value) =>
                {
                    let dateTime = SNMP.dateToReadable( value ).split( " " )
                    return `${dateTime[0]} ${dateTime[1]}`
                }, "str" ),
                "psJournalMode": new Wrappers.RowItem( Wrappers.RowTypes.TEXT, Wrappers.parseErrors, "str" ),
                "psJournalEvent": new Wrappers.RowItem( Wrappers.RowTypes.TEXT, (value) =>
                {
                    return Config[ "journal" ][ value.toString() ]
                }, "num" ),
            }

        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.maximumWidth: 1200
            Layout.fillWidth: true

            Button {
                highlighted: true
                text: "Назад"
                Material.accent: Globals.secondaryColor
                onClicked: {
                    if ( journalTable.currentPage == 1 ) return
                    journalTable.currentPage--
                }
            }

            Button {
                highlighted: true
                text: "Далее"
                Material.accent: Globals.accentColor
                onClicked: journalTable.currentPage++
            }

            Item{ Layout.fillWidth: true }

            Button {
                highlighted: true
                text: "Экспортировать"
                Material.accent: Globals.accentColor
                onClicked: messageDialog.open()
            }
        }
    }
}
