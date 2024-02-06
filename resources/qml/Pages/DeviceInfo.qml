import QtQuick
import QtQuick.Layouts

import "../Components"
import "../Globals"
import "../Models"

import "../wrappers.mjs" as Wrappers

Page
{
    property var configuration: Config[ "fields" ]
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
            activeColumns: 1

            headers: [
                TableHeaderM {
                    title: "Название"
                    expand: true
                },
                TableHeaderM {
                    title: "Значение"
                    expand: false
                }
            ]

            fields: [
                new Wrappers.ContentItem( null, "Серийный номер" ),
                new Wrappers.ContentItem( null, "Описание источника питания" ),
                new Wrappers.ContentItem( null, "Версия ПО контроллера" ),
                new Wrappers.ContentItem( null, "Время" ),

                new Wrappers.ContentItem( "psSerial", "", Wrappers.RowTypes.TEXT, "str" ),
                new Wrappers.ContentItem( "psDescription", "", Wrappers.RowTypes.TEXT, "str" ),
                new Wrappers.ContentItem( "psFWRevision", "", Wrappers.RowTypes.TEXT, "num", Wrappers.parseVersion ),
                new Wrappers.ContentItem( "psTime", "", Wrappers.RowTypes.TEXT, "str", (value) =>
                {
                    let dateTime = SNMP.dateToReadable( value ).split( " " )
                    return `${dateTime[0]}\n${dateTime[1]}`
                } )
            ]
        }
    }
}
