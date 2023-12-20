import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../Globals"

Item
{
    id: menu
    implicitWidth: 200

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        ColumnLayout {
            id: content

            anchors.fill: parent
            anchors.margins: 10

            ListView {
                id: list
                Layout.fillWidth: true
                Layout.fillHeight: true

                clip: true
                model: LeftMenuG.currentMenu
                boundsMovement: Flickable.StopAtBounds

                delegate: LeftMenuItem {
                    width: list.width
                    context: modelData
                }

                interactive: list.height < list.contentHeight
            }

            ListView {
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
                height: contentHeight

                clip: true
                interactive: false
                model: LeftMenuG.menuButtons

                delegate: LeftMenuItem {
                    width: list.width
                    context: modelData
                }
            }
        }
    }
}
