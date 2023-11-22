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

        TableComponent {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.maximumWidth: 1200
            tableOID: "psSignalRelayEntry"

            headers: [
                TableHeaderM {
                    title: "Номер реле"
                    expand: true
                },
                TableHeaderM {
                    title: "Количество событий"
                    expand: true
                }
            ]

            rows: {
                "psRelayNumber": new Wrappers.RowItem(),
                "psRelayEventAmount": new Wrappers.RowItem()
            }
        }
    }
}
