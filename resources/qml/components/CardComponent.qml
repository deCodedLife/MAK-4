import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import "../Globals"
import "../wrappers.mjs" as Wrappers

Rectangle
{
    id: root

    property string header: ""
    property var fields: []
    property var buttons: []

    signal fieldUpdated( index: string, value: string )

    Layout.alignment: Qt.AlignTop
    Layout.fillWidth: true

    color: "white"
    radius: 10
    height: contentColumn.implicitHeight + 20

    ColumnLayout
    {
        id: contentColumn
        width: parent.width
        height: implicitHeight

        Layout.topMargin: 20
        Layout.bottomMargin: 20

        spacing: 10

        ColumnLayout
        {
            Layout.fillWidth: true
            spacing: 0
            visible: header != ""

            Text {
                text: header
                font.pointSize: Globals.h4
                font.bold: true
                Layout.fillWidth: true
                Layout.margins: 20
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#F3F3F3"
            }
        }

        Item { visible: header == "" }
        Item { visible: header == "" }

        ColumnLayout {
            id: content
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            spacing: 20

            Layout.fillWidth: true
            height: implicitHeight

            ListView {
                id: contentList
                Layout.fillWidth: true
                height: contentHeight
                interactive: false
                spacing: 10

                model: fields

                delegate: Loader {
                    width: contentList.width
                    height: 52

                    id: customItem
                    property var fields: {
                        1: "CustomText.qml",
                        2: "CustomField.qml",
                        3: "CustomField.qml",
                        4: "CustomDropDown.qml",
                        5: "CustomSwitch.qml",
                        6: "CustomField.qml",
                        8: "CustomField.qml"
                    }

                    property int type: modelData[ "type" ]
                    property var value: modelData[ "value" ]
                    property var wrapper: modelData[ "wrapper" ]
                    property var model: modelData[ "model" ]

                    property int maxValue: {
                        let maxValue = modelData[ "max" ] ?? 2147483647
                        if ( wrapper )
                            return wrapper( maxValue )
                        return maxValue
                    }

                    property int minValue: {
                        let minValue = modelData[ "min" ] ?? -2147483647
                        if ( wrapper )
                            return wrapper( minValue )
                        return minValue
                    }

                    property string objectName: modelData[ "field" ]
                    property string placeholder: modelData[ "description" ]

                    property bool dobbledSwitch: true

                    function updateField( newValue ) {
                        if ( wrapper ) newValue = wrapper( newValue, true )
                        fieldUpdated( objectName, newValue )
                    }

                    source: fields[ type ]
                }
            }

            ListView
            {
                id: buttonsList
                Layout.fillWidth: true
                height: 42
                interactive: false
                spacing: 10
                orientation: ListView.Horizontal
                visible: buttons.length != 0

                model: buttons

                delegate: Button {
                    Layout.fillWidth: true
                    text: modelData[ "text" ]
                    highlighted: modelData[ "highlited" ]
                    Material.accent: modelData[ "color" ]
                    onClicked: {
                        modelData[ "callback" ]()
                        delay.start()
                    }
                    enabled: !delay.running

                    Timer
                    {
                        id: delay
                        interval: 3000
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Globals.grayScale
        radius: 10
        opacity: .6
        visible: !root.enabled
    }
}
