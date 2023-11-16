import QtQuick
import QtQuick.Layouts

import "../Components"
import "../Globals"
import "../Models"

import "../wrappers.mjs" as Wrappers

Page
{
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

        ColumnLayout {

            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.maximumWidth: 1200
            spacing: 10

            FieldsTable {
                id: infoTable
                Layout.alignment: Qt.AlignTop

                headers: [
                    TableHeaderM {
                        title: "Напряжение нагрузки, В"
                        expand: true
                    },
                    TableHeaderM {
                        title: "Ток нагрузки, А"
                        expand: true
                    },
                    TableHeaderM {
                        title: "Состояние нагрузки"
                        expand: true
                    }
                ]

                fields: [
                    new Wrappers.ContentItem( "psLoadVoltage", "", Wrappers.RowTypes.TEXT, "num", Wrappers.divideByHundred ),
                    new Wrappers.ContentItem( "psLoadCurrent", "", Wrappers.RowTypes.TEXT, "num", Wrappers.divideByThousand ),
                    new Wrappers.ContentItem( "psLoadStatus", "", Wrappers.RowTypes.TEXT, "str", Wrappers.parseErrors )
                ]
            }

            TableComponent {
                Layout.alignment: Qt.AlignTop
                tableOID: "psLoadFuseEntry"

                headers: [
                    TableHeaderM {
                        title: "№ АЗН"
                        expand: true
                    },
                    TableHeaderM {
                        title: "Состояние АЗН"
                        expand: true
                    }
                ]

                rows: {
                    "psLoadFuseNumber": new Wrappers.RowItem(),
                    "psLoadFuseStatus": new Wrappers.RowItem( Wrappers.RowTypes.DESCRIPTION, Wrappers.parseErrors, "str" )
                }
            }

        }
    }
}
