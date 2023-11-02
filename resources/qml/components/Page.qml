import QtQuick

import "../Globals"

Flickable
{
    id: page
    anchors.fill: parent
    clip: true

    interactive: height < contentHeight
    boundsMovement: Flickable.StopAtBounds

    Rectangle {
        width: page.width - 20
        height: page.height
        parent: page.parent
        x: 20
        color: Globals.backgroundColor
        z: -1
    }

    Rectangle {
        width: page.width
        height: page.height
        parent: page.parent
        radius: 10
        color: Globals.backgroundColor
        z: -1
    }
}
