import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import "../Globals"

Rectangle
{
    Layout.fillWidth: true
    height: contentLayout.implicitHeight

    property list<var> headers: []
    property list<var> content: []
    property int columnsCount: headers.length
    property int rowsCount: content.length / headers.length

    property string header: ""

    color: "white"
    radius: 10

    ColumnLayout {
        id: contentLayout
        width: parent.width
        height: implicitHeight
        spacing: 0

        Item{ Layout.topMargin: 20 }

        ColumnLayout
        {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true

            spacing: 0
            visible: header != ""

            Text {
                text: header
                font.pointSize: 16
                font.bold: true
                Layout.fillWidth: true
                Layout.leftMargin: 20
                Layout.rightMargin: 20
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#F3F3F3"
            }
        }


        RowLayout {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true

            Layout.leftMargin: 20
            Layout.rightMargin: 20

            Layout.topMargin: header != "" ? 20 : 0

            Repeater {
                model: headers

                Text {
                    id: simple

                    Layout.fillWidth: modelData[ "expand" ]
                    text: modelData[ "title" ]

                    color: Globals.textColor

                    horizontalAlignment: Text.AlignLeft
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                    font.bold: true
                    font.pointSize: 14
                }
            }
        }

        ColumnLayout {
            id: rowGrid
            Layout.alignment: Qt.AlignTop
            Layout.topMargin: 20
            spacing: 10

            Repeater {
                model: rowsCount

                ColumnLayout {
                    id: row
                    property int currentRow: index

                    CroppedLine {
                        Layout.alignment: Qt.AlignTop
                        Layout.fillWidth: true
                    }

                    RowLayout {

                        Layout.topMargin: 10
                        Layout.leftMargin: 20
                        Layout.rightMargin: 20

                        Repeater {
                            model: columnsCount

                            Item {
                                id: item

                                property var currentVar: content[ index + ( row.currentRow * columnsCount ) ]
                                property var value: SNMP.getOID( currentVar[ "field" ] )

                                height: itemText.contentHeight
                                Layout.preferredWidth: itemText.contentWidth
                                Layout.fillWidth: headers[ index ][ "expand" ]

                                function processValue() {
                                    let objectValue = currentVar[ "value" ]
                                    if ( currentVar[ "type" ] === 5 ) return objectValue

                                    if ( typeof( currentVar[ "wrapper" ] ) != "undefined" ) return item.currentVar[ "wrapper" ]( value )
                                    return value
                                }

                                Text {
                                    id: itemText
                                    width: item.width

                                    visible: item.currentVar[ "type" ] === 4 || item.currentVar[ "type" ] === 5
                                    text: processValue()

                                    color: "black"

                                    horizontalAlignment: Text.AlignLeft
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                                    font.bold: true
                                    font.pointSize: 14
                                }
                            }
                        }
                    }
                }
            }
        }

        Item{ Layout.topMargin: 20 }
    }

    Component.onCompleted: {
//        console.log( JSON.stringify( MIB.getObject() ) )
    }
}
