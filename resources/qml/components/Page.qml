import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

import "../Globals"

Flickable
{
    id: page
    anchors.fill: parent
    clip: true

    interactive: height < contentHeight
    boundsMovement: Flickable.StopAtBounds

    signal actionButtonTriggered

    property string actionButtonIcon
    property string actionButtonTitle
    property string actionButtonState

    Component.onCompleted: {
        if ( Qt.platform.os !== "windows" ) return
        flickDeceleration = 10000
    }

    ScrollBar.vertical: ScrollBar {
        id: control
        height: 10
        anchors.left: parent.left
        policy: ScrollBar.AsNeeded
        property Rectangle contentReference: contentItem
        visible: page.height < page.contentHeight

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

    Popup {
        id: popup

        x: page.parent.width - (width + 10)
        y: page.parent.height - (height + 30 + fab.height)

        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        contentItem: Text {
            id: popupText
            anchors.centerIn: parent
            text: actionButtonTitle
            font.pointSize: Globals.h6
            font.bold: true
            color: Globals.textColor
        }
    }

    RoundButton {
        id: fab
        parent: page.parent

        width: 72
        height: 72
        radius: 20

        display: Button.IconOnly
        Material.accent: Globals.accentColor

        x: page.parent.width - (width + 20)
        y: page.parent.height - (height + 20)

        visible: actionButtonIcon != ""
        highlighted: true

        icon.name: actionButtonIcon
        icon.source: actionButtonIcon
        icon.color: "white"
        icon.width: 28
        icon.height: 28

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: actionButtonTriggered()
            onHoveredChanged: containsMouse ? popup.open() : popup.close()
        }
    }
}
