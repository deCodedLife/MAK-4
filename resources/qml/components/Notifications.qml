import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import "../Globals"

Item
{
    property ListModel notifications: ListModel {
        ListElement{ type: 0; description: "fewfwefmeownfvoerigvfnoefvwep"; delay: 100000 }
        ListElement{ type: 0; description: "fewfwefmeownfvoerigvfnoefvwep"; delay: 100000 }

        onCountChanged: removeTimer.start()
    }

    Connections
    {
        target: SNMP
        function onNotify( type, description, delay ) {
            notifications.append( { "type": type, "description": description, "delay": delay } )
        }
    }

    ListView {
        id: list

        anchors.fill: parent
        anchors.margins: 20
        interactive: height < contentHeight
        verticalLayoutDirection: ListView.BottomToTop

        model: notifications
        spacing: 10

        remove: Transition {
            NumberAnimation {
                property: "x"
                to: 350
                duration: 200
                easing.type: Easing.InOutQuart
            }
            NumberAnimation {
                property: "opacity"
                to: 0
                duration: 200
                easing.type: Easing.Linear
            }
        }
        removeDisplaced:Transition{
            NumberAnimation{ property:"y"; duration: 500; easing.type: Easing.InOutQuad }
        }

        delegate: Item
        {
            width: list.width
            height: contentLayout.implicitHeight + 30

            Popup
            {
                width: parent.width
                height: parent.height

                opacity: parent.opacity

                id: popup
                focus: type === 1
                closePolicy: Popup.NoAutoClose

                contentItem: RowLayout {
                    id: contentLayout
                    spacing: 10
                    anchors.margins: 10
                    anchors.fill: parent

                    IconLabel {
                        id: eventItem
                        state: type === 0 ? "info" : "error"
                        states: [
                            State
                            {
                                name: "info"
                                PropertyChanges {
                                    target: eventItem
                                    icon.source: "qrc:/images/icons/notifications.svg"
                                    icon.color: "black"
                                }
                            },
                            State
                            {
                                name: "error"
                                PropertyChanges {
                                    target: eventItem
                                    icon.source: "qrc:/images/icons/error.svg"
                                    icon.color: "black"
                                }
                            }

                        ]

                    }
                    Text {
                        id: textItem
                        Layout.fillWidth: true
                        color: "black"
                        text: description
                        font.pointSize: Globals.h5
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }
                }

                Component.onCompleted: open()
            }
        }
    }

    Timer
    {
        id: removeTimer
        interval: 3000
        repeat: false
        running: true
        onTriggered: {
            if ( notifications.count <= 0 ) return
            list.model.remove( 0 )
        }
    }
}
