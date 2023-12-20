import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import "../Globals"

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
            spacing: 10

            Layout.fillWidth: true
            height: implicitHeight

            ListView {
                id: contentList
                Layout.fillWidth: true
                height: contentHeight
                interactive: false
                spacing: 10

                model: fields

                delegate: Item
                {
                    width: contentList.width
                    height: textfield.implicitHeight

                    CustomField {
                        property var counterValidator: IntValidator {
                            bottom: modelData[ "min" ] === -1 ? -2147483648 : modelData[ "min" ]
                            top: modelData[ "max" ] === -1 ? 2147483647 : modelData[ "max" ]
                        }

                        id: textfield
                        anchors.fill: parent
                        visible: modelData[ "type" ] === 2 || modelData[ "type" ] === 3 || modelData[ "type" ] === 6
                        placeholderText: modelData[ "description" ]
                        value: modelData[ "value" ]
                        onChanged: {
                            if ( !acceptableInput ) return
                            fieldUpdated( modelData[ "field" ], text )
                        }
                        echoMode: modelData[ "type" ] === 3 ? TextField.Password : TextField.Normal
                        validator: modelData[ "type" ] === 6 ? counterValidator : null
                        color: modelData[ "type" ] === 6 ? acceptableInput ? Globals.textColor : Globals.errorColor : Globals.textColor
                    }

                    CustomDropDown {
                        anchors.fill: parent
                        visible: modelData[ "type" ] === 4
                        displayText: `${modelData[ "description" ]}: ` + Object.keys( modelData[ "model" ] )[ currentIndex ]
                        value: modelData[ "value" ]
                        model: Object.keys( modelData[ "model" ] )
                        onCurrentIndexChanged: {
                            if ( preSelected === currentIndex ) return
                            preSelected = currentIndex
                            fieldUpdated( modelData[ "field" ], Object.keys( modelData[ "model" ] )[ currentIndex ] )
                        }
                    }

                    CustomSwitch {
                        id: customSwitch
                        anchors.fill: parent
                        visible: modelData[ "type" ] === 5
                        text: modelData[ "description" ]
                        toggled: modelData[ "value" ]
                        dobbled: true
                        onContentChanged: value => fieldUpdated( modelData[ "field" ], value )
                    }
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
