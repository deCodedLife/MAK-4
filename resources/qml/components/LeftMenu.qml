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

        ListView {
            id: list
            anchors.fill: parent

//            Layout.alignment: Qt.AlignTop
//            Layout.fillHeight: true
//            Layout.fillWidth: true

            anchors.margins: 10
            clip: true
            model: LeftMenuG.currentMenu
            boundsMovement: Flickable.StopAtBounds

            delegate: LeftMenuItem {
                width: list.width
                context: modelData
            }

            interactive: list.height < list.contentHeight
        }

        Flickable
        {
            anchors.fill: parent
            contentHeight: content.implicitHeight
            interactive: contentHeight > height

            ColumnLayout {
                id: content

                anchors.fill: parent
                anchors.margins: 10



//                ListView {

//                    Layout.alignment: Qt.AlignBottom
//                    Layout.fillWidth: true
//                    height: contentHeight

//                    anchors.margins: 10
//                    clip: true
//                    model: LeftMenuG.menuButtons
//                    boundsMovement: Flickable.StopAtBounds

//                    delegate: LeftMenuItem {
//                        width: list.width
//                        context: modelData
//                    }

//                    interactive: list.height < list.contentHeight
//                }
            }
        }
    }
}
