import QtQuick
import QtQuick.Layouts

Item
{
    height: layout.implicitHeight + 20

    RowLayout {
        id: layout

        anchors.fill: parent
        spacing: 10

        Rectangle {
            Layout.alignment: Qt.AlignVCenter

            width: 16
            height: 16
            radius: width / 2

            color: "grey"
        }

        Text {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            text: "Нет соединения"
            color: "white"

            horizontalAlignment: Text.AlignLeft
            font.bold: true
            font.pointSize: 12
        }
    }
}
