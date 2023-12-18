import QtQuick
import QtQuick.Layouts

import "../wrappers.mjs" as Wrappers
import "../Components"
import "../Globals"
import "../Models"

Page {
    contentHeight: content.implicitHeight + 20

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
            tableOID: "psVbvEntry"
            updateInterval: Math.max( ConfigManager.get()[ "main" ][ "updateDelay" ][ "value" ] * 1000, 10000 )

            headers: [
                TableHeaderM {
                    title: "№"
                },
                TableHeaderM {
                    title: "Входное\nнапряжение, В"
                    expand: true
                },
                TableHeaderM {
                    title: "Выходное\nнапряжение, В"
                    expand: true
                },
                TableHeaderM {
                    title: "Ток, А"
                    expand: true
                },
                TableHeaderM {
                    title: "Температура, °C"
                    expand: true
                },
                TableHeaderM {
                    title: "Состояние"
                }
            ]

            rows: {
                "psVbvNumber": new Wrappers.RowItem(),
                "psVbvInpVoltage": new Wrappers.RowItem( Wrappers.RowTypes.DESCRIPTION, Wrappers.divideByHundred ),
                "psVbvVoltage": new Wrappers.RowItem(),
                "psVbvCurrent": new Wrappers.RowItem( Wrappers.RowTypes.DESCRIPTION, Wrappers.divideByThousand ),
                "psVbvTemperature": new Wrappers.RowItem(),
                "psVbvStatus": new Wrappers.RowItem( Wrappers.RowTypes.DESCRIPTION, Wrappers.parseErrors, "str" )
            }
        }
    }
}
