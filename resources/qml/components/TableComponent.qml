import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import "../Globals"

Rectangle
{
    id: root

    Layout.fillWidth: true
    Layout.preferredHeight: contentLayout.implicitHeight + ( flickable.width < flickable.contentWidth ? 20 : 0 )

    property var rows
    property var content

    property list<Item> headers: []
//    property list<string> values: SNMP.getOIDs( content.map( object => object[ "-" ] ?? "" ) )
    property string tableOID

    property int columnsCount: headers.length
    property int rowsCount

    property string header: ""

    color: "white"
    radius: 10

    Connections
    {
        target: SNMP
        function onGotTablesCount( root, rows ) {
            if ( root !== tableOID ) return
//            console.log( rows )
//            rowsCount = parseInt( rows )
        }

        function onGotRowsContent( root: string, data: object ) {
            if ( root !== tableOID ) return

            let _rowsCount = data[ Object.keys( rows )[ 0 ] ].length
            let _rowsNames = Object.keys( rows )

            console.log( JSON.stringify( content ) )

            for ( let columnIndex  = 0; columnIndex < _rowsCount; columnIndex++ )
            {

                for ( let rowIndex = 0; rowIndex < _rowsNames.length; rowIndex++ )
                {
                    let rowName = _rowsNames[ rowIndex ]
                    let row = data[ rowName ][ columnIndex ]

                    row[ "type" ] = 5

                    let rowData = row[ rows[ rowName ][ "key" ] ]
                    let rowDataWrapper = rows[ rowName ][ "wrapper" ]
                    if ( rowDataWrapper ) rowData = rowDataWrapper( rowData )

                    row[ "value" ] = rowData
                    content[ rowName ].push( row )
                }

            }

            rowsCount = _rowsCount
        }
    }

    Component.onCompleted: {
        let rowNames = Object.keys( rows )
        content = {}

        for ( let rowIndex = 0; rowIndex < rowNames.length; rowIndex++ )
            content[ rowNames[ rowIndex ] ] = []

        SNMP.getRows( tableOID )
    }

    Flickable
    {
        id: flickable

        interactive: width < contentWidth || height < contentHeight
        contentHeight: contentLayout.implicitHeight
        contentWidth: contentLayout.implicitWidth
        clip: true
        boundsMovement: Flickable.StopAtBounds

        width: root.width
        height: contentLayout.implicitHeight + ( width < contentWidth ? 20 : 0 )

        ScrollBar.horizontal: ScrollBar {
            id: control
            width: 10
            anchors.bottom: parent.bottom
            policy: ScrollBar.AsNeeded
            property Rectangle contentReference: contentItem
            visible: flickable.width < flickable.contentWidth

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

        ColumnLayout {
            id: contentLayout
            width: gridLayout.implicitWidth > root.width ? gridLayout.implicitWidth : root.width
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
                    model: content.length
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
                            Layout.fillWidth: headers[ index ][ "expand" ]
                            Layout.minimumWidth: headers[ index ][ "expand" ] === false ? itemText.implicitWidth : null

                            Layout.preferredHeight: {
                                if ( itemText.visible ) return itemText.contentHeight
                                if ( switchValue.visible ) return switchValue.height
                            }

                            Layout.preferredWidth: headers[ index ][ "expand" ]  === false ? itemText.contentWidth : null

                            Layout.leftMargin: index === 0 ? 20 : 0
                            Layout.rightMargin: (index === headers.length - 1) ? 20 : 0

                            property var currentVar: content[ Object.keys( rows )[ index ] ][ row.currentRow ]
                            property var type: {
                                if ( typeof( item.currentVar[ "type" ] ) == "undefined" ) return 5
                                return item.currentVar[ "type" ]
                            }

                            onWidthChanged: height = itemText.contentHeight

                            CustomSwitch {
                                id: switchValue
                                width: item.width
                                visible: item.type === 6

                                toggled: {
                                    if (item.type !== 6) return false
                                    else parseInt( values[ index + ( row.currentRow * columnsCount ) ] ) === 1
                                }

                                onContentChanged: value => {
                                    let wrapper = item.currentVar[ "wrapper" ]
                                    wrapper( value )
                                }
                            }

                            Text {
                                id: itemText
                                width: item.width

                                visible: item.type === 4 || item.type === 5
                                text: item.currentVar[ "value" ]

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

    Rectangle {
        anchors.fill: parent
        color: Globals.grayScale
        radius: 10
        opacity: .6
        visible: !root.enabled
    }
}
