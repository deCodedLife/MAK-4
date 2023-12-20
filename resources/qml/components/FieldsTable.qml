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

    property var content
    property var fields

    property int columnsCount: headers.length
    property int rowsCount

    property bool loaded
    property string header: ""
    property list<Item> headers
    property int updateInterval: ConfigManager.get()[ "main" ][ "updateDelay" ][ "value" ] * 1000

    color: "white"
    radius: 10

    function updateViaContent( row )
    {
        content = []

        let infoItems = fields.filter( field => field.type === 1 )
        infoItems.map( field => {
            let row = {}
            row[ "type" ] = field.type
            row[ "value" ] = field.description
            content.push( row )
        } )

        let _rowNames = headers.map( h => h.title )
        let fieldsRows = fields.length / _rowNames.length;

        for ( let rowIndex = 0; rowIndex < _rowNames.length; rowIndex++ )
        {
            let rowSlice = fields.slice( rowIndex * fieldsRows, ( rowIndex + 1 ) * fieldsRows )
            let oidsMap = rowSlice.map( field => field.oid ?? "" )
            oidsMap = oidsMap.filter( oid => oid !== "" )

            if ( oidsMap.length === 0 ) continue
            SNMP.getOIDs( _rowNames[ rowIndex ], oidsMap )
        }
    }

    Connections
    {
        target: SNMP

        function onGotRowsContent( root: string, data: object )
        {
            let foundHeaders = headers.filter( h => h.title === root )
            if ( foundHeaders.length === 0 ) return

            let rawFields = Object.keys( data )
            let rowPerCol = fields.length / headers.length
            let startFrom = headers.indexOf( foundHeaders[0] ) * rowPerCol


            for ( let fieldIndex = startFrom; fieldIndex < (startFrom + rowPerCol); fieldIndex++ )
            {
                let field = fields[ fieldIndex ]
                let row = data[ field.oid ]
                row[ "oid" ] = field.oid
                row[ "type" ] = field.type
                row[ "value" ] = field.wrapper( row[ field.key ] )

                content.push( row )
            }

            if ( startFrom + rowPerCol === fields.length ) {
                loaded = true
                rowsCount = 0
                rowsCount = rowPerCol
            }
        }
    }

    Flickable {
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
                    font.pointSize: Globals.h4
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
                        font.pointSize: Globals.h5
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
                            Layout.fillWidth: headers[ index ][ "expand" ]
                            Layout.minimumWidth: headers[ index ][ "expand" ] === false ? itemText.implicitWidth : null

                            Layout.preferredHeight: {
                                if ( itemText.visible ) return itemText.contentHeight
                                if ( switchValue.visible ) return switchValue.height

                                return 0
                            }

                            Layout.preferredWidth: headers[ index ][ "expand" ]  === false ? itemText.contentWidth : null

                            Layout.leftMargin: index === 0 ? 20 : 0
                            Layout.rightMargin: (index === headers.length - 1) ? 20 : 0

                            property var currentVar: content[ row.currentRow + index * rowsCount ] ?? { type: 1, value: " " }
                            property var type: {
                                if ( typeof( item.currentVar[ "type" ] ) == "undefined" ) return 1
                                return item.currentVar[ "type" ]
                            }

                            onWidthChanged: height = itemText.contentHeight

                            CustomSwitch {
                                id: switchValue
                                width: item.width
                                visible: item.type === 5

                                toggled: {
                                    if (item.type !== 5) return false
                                    else item.currentVar[ "value" ] === 1
                                }

                                onContentChanged:
                                    value =>
                                    SNMP.setOID( item.currentVar[ "oid" ], value )
                            }

                            Text {
                                id: itemText
                                width: item.width

                                visible: item.type === 0 || item.type === 1
                                text: item.currentVar[ "value" ]

                                color: "black"

                                horizontalAlignment: Text.AlignLeft
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                                font.bold: true
                                font.pointSize: Globals.h5

                            }
                        }
                    }
                }
            }

            ProgressBar {
                Layout.fillWidth: true
                Layout.margins: {
                    left: 20
                    right: 20
                    bottom: 20
                }
                indeterminate: true
                visible: !loaded
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

    Timer
    {
        id: updateTableTimer
        triggeredOnStart: true
        repeat: true
        running: true
        interval: updateInterval
        onTriggered: updateViaContent()
    }
}
