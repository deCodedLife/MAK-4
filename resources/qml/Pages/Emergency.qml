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

        RowLayout {

            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.maximumWidth: 1200
            spacing: 10

            TableComponent {
                id: firstTable
                Layout.alignment: Qt.AlignTop
                header: "Таблица аварий 1-й степени"
                tableOID: "psAlarm1Entry"

                headers: [
                    TableHeaderM {
                        title: "Номер"
                        expand: false
                    },
                    TableHeaderM {
                        title: "Название аварии 1 степени"
                        expand: true
                    }
                ]

                rows: {
                    "psAlarm1Number": new Wrappers.RowItem(),
                    "psAlarm1Event": new Wrappers.RowItem( Wrappers.RowTypes.DESCRIPTION, (value) => Config[ "errors" ][ value ] )
                }
            }

            TableComponent {
                Layout.alignment: Qt.AlignTop
                header: "Таблица аварий 2-й степени"
                tableOID: "psAlarm2Entry"

                headers: [
                    TableHeaderM {
                        title: "Номер"
                        expand: false
                    },
                    TableHeaderM {
                        title: "Название аварии 2 степени"
                        expand: true
                    }
                ]

                rows: {
                    "psAlarm2Number": new Wrappers.RowItem(),
                    "psAlarm2Event": new Wrappers.RowItem( Wrappers.RowTypes.DESCRIPTION, (value) => Config[ "errors" ][ value ] )
                }
            }

        }
    }
}
