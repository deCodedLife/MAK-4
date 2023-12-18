import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

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

        FieldsTable {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.maximumWidth: 1200
            activeColumns: 5

            headers: [
                TableHeaderM { title: "Температура 1, °C"; expand: false },
                TableHeaderM { title: "Средняя Температура, °C"; expand: false },
                TableHeaderM { title: "Состояние Датчика 1"; expand: false },
                TableHeaderM { title: "Температура 2, °C"; expand: false },
                TableHeaderM { title: "Состояние Датчика 2"; expand: false }
            ]

            fields: [
                new Wrappers.ContentItem( "psTemperature1", "", Wrappers.RowTypes.TEXT, "num", Wrappers.divideByTen ),
                new Wrappers.ContentItem( "psMeanTemperature1", "", Wrappers.RowTypes.TEXT, "num", Wrappers.divideByTen ),
                new Wrappers.ContentItem( "psTemperature1Status", "", Wrappers.RowTypes.TEXT, "str", Wrappers.parseErrors ),
                new Wrappers.ContentItem( "psTemperature2", "", Wrappers.RowTypes.TEXT, "num", Wrappers.divideByTen ),
                new Wrappers.ContentItem( "psTemperature2Status", "", Wrappers.RowTypes.TEXT, "str", Wrappers.parseErrors ),
            ]
        }
    }
}
