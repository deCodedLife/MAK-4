import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import "../Globals"

Rectangle
{
    id: root

    Layout.fillWidth: true
    height: contentLayout.implicitHeight

    property list<var> headers: []
    property list<var> content
    property list<string> values: SNMP.getOIDs( content.map( object => object[ "field" ] ?? "" ) )

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

            spacing: 10
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

        GridLayout {
            id: gridLayout

            Layout.alignment: Qt.AlignTop
            Layout.topMargin: header != "" ? 10 : 0
            Layout.bottomMargin: 20

            rows: rowsCount * 2 + 1
            columns: columnsCount

            rowSpacing: 10
            columnSpacing: 10

            Repeater {
                model: headers

                Text {
                    id: simple

                    Layout.row: 1
                    Layout.column: index

                    Layout.leftMargin: index === 0 ? 20 : 0
                    Layout.rightMargin: index === headers.length - 1 ? 20 : 0

                    Layout.fillWidth: modelData[ "expand" ]
                    text: modelData[ "title" ]

                    color: Globals.textColor

                    horizontalAlignment: Text.AlignLeft
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                    font.bold: true
                    font.pointSize: 14
                }
            }


            Repeater {
                model: rowsCount
                Item {
                    Layout.row: (index + 1) * 2
                    width: 0
                    height: 0
                    CroppedLine {
                        width: gridLayout.width
                    }
                }
            }

            Repeater {
                model: rowsCount

                Repeater {
                    id: row
                    property int currentRow: index

                    model: columnsCount

                    Item {
                        id: item

                        Layout.row: (row.currentRow + 1) * 2 + 1
                        Layout.column: index

                        Layout.leftMargin: index === 0 ? 20 : 0
                        Layout.rightMargin: (index === headers.length - 1) ? 20 : 0

                        width: itemText.contentWidth

                        property var currentVar: content[ index + ( row.currentRow * columnsCount ) ]

                        height: itemText.contentHeight

                        Text {
                            id: itemText
                            width: item.width

                            visible: item.currentVar[ "type" ] === 4 || item.currentVar[ "type" ] === 5
                            text: {
                                if ( item.currentVar[ "type" ] === 5 ) return currentVar[ "value" ]
                                let wrapper = item.currentVar[ "wrapper" ]
                                if ( typeof( wrapper ) == "undefined"  ) return values[ index + ( row.currentRow * columnsCount ) ]
                                return wrapper( values[ index + ( row.currentRow * columnsCount ) ] )
                            }

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
