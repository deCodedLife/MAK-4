import QtQuick
import QtQuick.Layouts

import "../Globals"

Item
{
    id: control

    property string text
    property bool toggled: false
    property bool dobbled: false

    signal contentChanged( int value )
    state: toggled ? "enabled" : "disabled"

    Layout.fillWidth: true
    height: content.implicitHeight

    RowLayout {
        id: content
        anchors.fill: parent

        spacing: dobbled ? 10 : 5

        Rectangle {
            id: background
            Layout.alignment: Qt.AlignVCenter

            radius: 10
            width: 38
            height: 20

            state: control.state
            states: [
                State {
                    name: "enabled"
                    PropertyChanges {
                        target: background
                        color: Globals.accentColor
                    }
                },
                State {
                    name: "disabled"
                    PropertyChanges {
                        target: background
                        color: Globals.grayScale
                    }
                }
            ]

            transitions: Transition {
                ColorAnimation { duration: 200 }
            }

            Rectangle {
                id: ripple
                y: (background.height / 2) - (height / 2)

                color: "white"
                width: background.height / 2
                height: width
                radius: width / 2


                state: control.state
                states: [
                    State {
                        name: "enabled"
                        PropertyChanges {
                            target: ripple
                            x: background.width - ( 5 + ripple.width )
                        }
                    },
                    State {
                        name: "disabled"
                        PropertyChanges {
                            target: ripple
                            x: 5
                        }
                    }
                ]
                transitions: Transition {
                    NumberAnimation { property: "x"; easing.type: Easing.InOutQuad; duration: 200 }
                }
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            horizontalAlignment: Text.AlignLeft

            text: control.text
            color: Globals.textColor

            font.bold: true
            font.pointSize: dobbled ? Globals.h5 : Globals.h6
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            toggled = !toggled
            contentChanged( toggled )
        }
    }
}
