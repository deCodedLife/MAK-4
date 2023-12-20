import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import "../Globals"
import "../wrappers.mjs" as Wrappers

Rectangle
{
    id: root

    Layout.fillWidth: true
    Layout.preferredHeight: contentLayout.implicitHeight + ( flickable.width < flickable.contentWidth ? 20 : 0 )

    property var content
    property var fields

    property int columnsCount: headers.length
    property int activeColumns
    property int rowsCount

    property bool loaded
    property bool autoUpdate: true
    property bool hideSeparators: false
    property string header: ""
    property string hashRoot
    property list<Item> headers
    property int updateInterval: ConfigManager.get()[ "main" ][ "updateDelay" ][ "value" ] * 1000

    color: "white"
    radius: 10

    function updateViaContent()
    {
        content = []
        hashRoot = Wrappers.md5( fields[ 0 ].oid ?? fields[ 0 ].description )

        var _request = []

        for ( let _index = 0; _index < fields.length; _index++ )
        {
            let field = fields[ _index ]
            if ( field.type !== 1 && field.oid ) {
                _request.push( field.oid + ".0" )
                continue
            }

            content.push( {
                "type": field.type,
                "value": field.description
            } )
        }

        SNMP.getOIDs( hashRoot, _request )
    }

    Connections
    {
        target: SNMP

        function onGotRowsContent( root: string, data: object )
        {
            if ( root !== hashRoot ) return

            for ( let _indexData = 0; _indexData < fields.length; _indexData++ )
            {
                if ( !fields[ _indexData ].oid ) continue

                content.push( {
                    "oid": fields[ _indexData ].oid,
                    "type": fields[ _indexData ].type,
                    "value": fields[ _indexData ].wrapper( data[ fields[ _indexData ].oid ][ fields[ _indexData ].key ] )
                })
            }

            loaded = true
            rowsCount = 0
            rowsCount = Object.keys( data ).length / activeColumns
        }
    }

    Flickable {
        id: flickable

        interactive: width < contentWidth
        // contentHeight: contentLayout.implicitHeight
        contentWidth: contentLayout.implicitWidth
        clip: true
        boundsMovement: Flickable.StopAtBounds

        width: root.width
        height: contentLayout.implicitHeight + ( width < contentWidth ? 20 : 0 )
        // height: root.height

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

            onHeightChanged: flickable.contentHeight = implicitHeight

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
                    enabled: !hideSeparators
                    visible: !hideSeparators
                    model: rowsCount
                    Item {
                        enabled: !hideSeparators
                        visible: !hideSeparators
                        Layout.row: (index + 1) * 2
                        width: 0
                        height: 0
                        CroppedLine {
                            enabled: !hideSeparators
                            visible: !hideSeparators
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
                            height: _height

                            Layout.row: (row.currentRow + 1) * 2 + 1
                            Layout.column: index
                            Layout.fillWidth: headers[ index ][ "expand" ]
                            Layout.minimumWidth: headers[ index ][ "expand" ] === false ? itemText.implicitWidth : null

                            property int _height: {
                                if ( itemText.visible ) return itemText.contentHeight
                                if ( checkbox.visible ) return checkbox.height
                                if ( switchValue.visible ) return switchValue.height
                                return 0
                            }

                            Layout.preferredHeight: _height
                            Layout.preferredWidth: headers[ index ][ "expand" ]  === false ? itemText.contentWidth : null
                            onWidthChanged: height = itemText.contentHeight

                            Layout.leftMargin: index === 0 ? 20 : 0
                            Layout.rightMargin: (index === headers.length - 1) ? 20 : 0

                            property var currentVar: content[ row.currentRow + index * rowsCount ] ?? { type: 1, value: " " }
                            property var type: {
                                if ( typeof( item.currentVar[ "type" ] ) == "undefined" ) return 1
                                return item.currentVar[ "type" ]
                            }

                            CustomSwitch {
                                id: switchValue
                                width: item.width
                                visible: item.type === 5
                                anchors.centerIn: parent
                                property bool previousState: item.currentVar[ "value" ] === 1

                                toggled: {
                                    if (item.type !== 5) return false
                                    else item.currentVar[ "value" ] === 1
                                }

                                onContentChanged: checked => {
                                    if ( checked === previousState ) return
                                    SNMP.setOID( item.currentVar[ "oid" ], checked ? 1 : 0 )
                                    previousState = checked
                                }
                            }

                            CustomCheckbox {
                                id: checkbox
                                visible: item.type === 7
                                property bool previousState: item.currentVar[ "value" ] === 1

                                checked: {
                                    if ( item.type !== 7 ) return false
                                    else item.currentVar[ "value" ] === 1
                                }

                                onCheckedChanged: {
                                    if ( checked === previousState ) return
                                    SNMP.setOID( item.currentVar[ "oid" ], checked ? 1 : 0 )
                                    previousState = checked
                                }
                            }

                            Text {
                                id: itemText
                                width: item.width
                                anchors.centerIn: parent

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
        onTriggered: {
            if ( !autoUpdate ) return
            updateViaContent()
        }
    }
}
