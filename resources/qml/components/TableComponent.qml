import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import "../Globals"

Rectangle
{
    id: root

    Layout.fillWidth: true
    Layout.preferredHeight: contentLayout.implicitHeight

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
        width: root.width
        spacing: 0

        Item{ Layout.topMargin: 20 }

        ColumnLayout
        {
            id: headerLayout

            Layout.alignment: Qt.AlignTop
            width: contentLayout.width

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
            clip: true

            width: contentLayout.width
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
                        height: itemText.contentHeight

                        Layout.row: (row.currentRow + 1) * 2 + 1
                        Layout.column: index
                        Layout.fillWidth: true
                        Layout.preferredHeight: itemText.contentHeight

                        Layout.leftMargin: index === 0 ? 20 : 0
                        Layout.rightMargin: (index === headers.length - 1) ? 20 : 0

                        property var currentVar: content[ index + ( row.currentRow * columnsCount ) ]
                        property var type: {
                            if ( typeof( item.currentVar[ "type" ] ) == "undefined" ) return 5
                            return item.currentVar[ "type" ]
                        }

                        onWidthChanged: height = itemText.contentHeight

                        Text {
                            id: itemText
                            width: item.width

                            visible: item.type === 4 || item.type === 5
                            text: {
                                let value = item.currentVar[ "value" ] ?? ""
                                let wrapper = item.currentVar[ "wrapper" ]

                                if ( item.type === 5 ) value = item.currentVar[ "value" ]
                                else value = values[ index + ( row.currentRow * columnsCount ) ]

                                if ( typeof( wrapper ) == "undefined" ) return value
                                return wrapper( value )
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
