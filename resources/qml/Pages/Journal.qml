import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import "../Components"
import "../Globals"
import "../Models"
import "../wrappers.mjs" as Wrappers


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

        JournalTable {
            id: journalTable
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.maximumWidth: 1200
            tableOID: "psJournalEntry"
            rowsLength: width == 1200 ? 25 : 18

            footer: `Текущая страница: ${journalTable.currentPage}`

            headers: [
                TableHeaderM { title: "Номер события"; expand: true },
                TableHeaderM { title: "Время события"; expand: true },
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
                text: "Далее"
                Material.accent: Globals.accentColor
                onClicked: journalTable.currentPage++
            }

            Button {
                highlighted: true
                text: "Назад"
                Material.accent: Globals.secondaryColor
                onClicked: journalTable.currentPage--
            }

            Item{ Layout.fillWidth: true }
        }
    }
}
