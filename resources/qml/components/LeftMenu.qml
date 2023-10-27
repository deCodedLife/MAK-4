import QtQuick
import QtQuick.Controls

import "../Globals"

Item
{
    implicitWidth: 200

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        ListView {
            id: list

            anchors.fill: parent
            anchors.margins: 10
            clip: true
            model: LeftMenuG.mainList
            boundsMovement: Flickable.StopAtBounds

            delegate: LeftMenuItem {
                width: list.width
                context: modelData
            }

            interactive: list.height < list.contentHeight
        }
    }
}
