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

                ScrollBar.vertical: ScrollBar {
                    id: control
                    height: 10
                    policy: ScrollBar.AsNeeded
                    property Rectangle contentReference: contentItem
                    visible: list.height < list.contentHeight

                    Component.onCompleted: {
                        contentReference.radius = 5
                        contentReference.opacity = .6
                    }

                    background: Rectangle {
                        implicitWidth: control.interactive ? 16 : 4
                        implicitHeight: control.interactive ? 16 : 4
                        color: "transparent"
                        opacity: .6
                        visible: control.interactive
                    }
                }

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
