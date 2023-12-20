import QtQuick
import QtQuick.Layouts

import "../Components"
import "../Globals"
import "../Models"

import "../wrappers.mjs" as Wrappers

Page
{
    property var configuration: Config[ "masks" ]
    property var tableHeaders: Config[ "errors" ]

    contentHeight: content.implicitHeight + 20

    function addWrapper( config, wrapper ) {
        config[ "wrapper" ] = wrapper
        return config
    }

    ColumnLayout {
        id: content

        anchors.fill: parent
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        anchors.leftMargin: 20
        anchors.rightMargin: 20

        FieldsTable {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.maximumWidth: 1200
            updateInterval: Math.max( ConfigManager.get()[ "main" ][ "updateDelay" ][ "value" ] * 1000, 10000 )
            activeColumns: 6
            autoUpdate: false
            hideSeparators: true

            headers: [
                TableHeaderM {
                    title: "Название маски"
                    expand: true
                },
                TableHeaderM {
                    title: "Авария 1"
                    expand: false
                },
                TableHeaderM {
                    title: "Авария 2"
                    expand: false
                },
                TableHeaderM {
                    title: "Реле 1"
                    expand: false
                },
                TableHeaderM {
                    title: "Реле 2"
                    expand: false
                },
                TableHeaderM {
                    title: "Реле 3"
                    expand: false
                },
                TableHeaderM {
                    title: "Реле 4"
                    expand: false
                }
            ]

            fields: {
                let _fields = [];

                for ( let [key, value] of Object.entries( tableHeaders ) )
                    _fields.push( new Wrappers.ContentItem( null, value ) )

                for ( let [key, value] of Object.entries( configuration ) )
                    _fields.push( new Wrappers.ContentItem( value[ 0 ], value[ 1 ][ "description" ], 7, "num" ) )

                return _fields;
            }

           Component.onCompleted: updateViaContent()
        }
    }
}
