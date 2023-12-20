import QtQuick

import "../Globals"

Item
{
    id: page
    anchors.fill: parent
    clip: true

    Rectangle {
        anchors.fill: page
        anchors.leftMargin: 20
        color: Globals.backgroundColor
    }

    Rectangle {
        anchors.fill: page
        radius: 10
        color: Globals.backgroundColor
    }
}
