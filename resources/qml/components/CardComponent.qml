import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

Rectangle
{
    color: "white"
    radius: 10

    property string header: ""

    Layout.alignment: Qt.AlignTop
    Layout.fillWidth: true
//    Layout.fillHeight: true
    height: contentColumn.implicitHeight + 20

    property var fields: []
    property var buttons: []

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
                font.pointSize: 16
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
                        id: textfield
                        anchors.fill: parent
                        visible: modelData[ "type" ] === 0
                        placeholderText: modelData[ "description" ]
                        value: modelData[ "value" ]
                    }

                    CustomDropDown {
                        anchors.fill: parent
                        visible: modelData[ "type" ] === 1
                        displayText: `${modelData[ "description" ]}: ${modelData[ "model" ][ currentIndex ]}`
                        preSelected: parseInt( modelData[ "value" ] )
                        model: modelData[ "model" ]
                        onCurrentIndexChanged: {
                            modelData[ "value" ] = currentIndex
                        }
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
                    onClicked: modelData[ "callback" ]()
                }
            }
        }
    }


}
