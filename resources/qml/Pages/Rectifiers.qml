import QtQuick
import QtQuick.Layouts

import "../Components/wrappers.mjs" as Wrappers
import "../Components"
import "../Globals"

Page
{
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

            headers: [
                TableHeaderM{ title: "№" },
                TableHeaderM{ title: "Входное\nнапряжение, В"; expand: true },
                TableHeaderM{ title: "Выходное\nнапряжение, В"; expand: true },
                TableHeaderM{ title: "Температура, °C"; expand: true },
                TableHeaderM{ title: "Ток, А"; expand: true },
                TableHeaderM{ title: "Состояние" }
            ]

            rows: {
                "psVbvNumber": { key: "num", wrapper: null },
                "psVbvInpVoltage": { key: "num", wrapper: Wrappers.divideByHundred },
                "psVbvVoltage": { key: "num", wrapper: null },
                "psVbvTemperature": { key: "num", wrapper: null },
                "psVbvCurrent": { key: "num", wrapper: Wrappers.divideByThousand, },
                "psVbvStatus": { key: "str", wrapper: Wrappers.parseErrors},
            }
        }
    }
}
