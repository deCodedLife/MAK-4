import QtQuick

import "../Globals"

Rectangle
{
    property bool checked

    width: 16
    height: 16
    radius: 5

    color: checked ? Globals.accentColor : Globals.grayScale

    MouseArea
    {
        anchors.fill: parent
        onClicked: checked = !checked
    }
}
