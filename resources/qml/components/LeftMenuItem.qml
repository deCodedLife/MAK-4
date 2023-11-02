import QtQuick
import QtQuick.Layouts

import "../Globals"

Rectangle
{
    id: root

    property MenuItemM context: null
    height: menuItem.implicitHeight + 20

    radius: 10
    state: context.page == PageLoaderG.currentPage ? "highlited" : "default"

    Connections {
        target: PageLoaderG

        function onCurrentPageChanged() {
            root.state = context.page === PageLoaderG.currentPage ? "highlited" : "default"
        }
    }

    states: [
        State {
            name: "default"
            PropertyChanges {
                target: root
                color: "transparent"
            }
        },
        State {
            name: "highlited"
            PropertyChanges {
                target: root
                color: Globals.secondaryColor
            }
        }
    ]

    RowLayout {
        id: menuItem
        anchors.fill: parent
        anchors.margins: 10
        spacing: 20

        Image {
            source: LeftMenuG.iconsLocation + context.icon
        }

        Text {
            Layout.fillWidth: true

            text: context.title
            color: "white"

            horizontalAlignment: Text.AlignLeft
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere

            font.bold: false
            font.pointSize: 12
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onHoveredChanged: {
            if ( context.page == PageLoaderG.currentPage ) return
            if ( containsMouse ) root.state = "highlited"
            else root.state = "default"
        }

        onClicked: {
            if ( context.page == PageLoaderG.currentPage ) return
            PageLoaderG.currentPage = context.page
        }
    }

}
