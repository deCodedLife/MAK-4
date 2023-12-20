import QtQuick
import QtQuick.Layouts

import "../Globals"

Item
{
    height: layout.implicitHeight + 20

    property int currentState: 0

    Connections {
        target: SNMP

        function onStateChanged() {
            currentState = SNMP.state()
        }
    }

    RowLayout {
        id: layout

        anchors.fill: parent
        spacing: 10

        Rectangle {
            Layout.alignment: Qt.AlignVCenter

            width: 16
            height: 16
            radius: width / 2

            color: currentState == 1 ? Globals.succsessColor : Globals.grayAccent
        }

        Text {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            text: currentState == 1 ? "Соединение установлено" : "Нет соединения"
            color: "white"

            horizontalAlignment: Text.AlignLeft
            font.bold: true
            font.pointSize: Globals.h6
        }
    }
}
