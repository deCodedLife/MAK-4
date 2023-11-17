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
    id: root
    contentHeight: content.implicitHeight

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

            CustomSwitch {
                id: handControl
                text: "Ручное управление"
            }

            FieldsTable {
                id: table
                Layout.alignment: Qt.AlignTop
                enabled: handControl.toggled

                headers: [
                    TableHeaderM {
                        title: "Контактор"
                        expand: true
                    },
                    TableHeaderM {
                        title: "Состояние"
                        expand: true
                    }
                ]

                fields: [
                    new Wrappers.ContentItem( null, "psContactorSycnro" ),
                    new Wrappers.ContentItem( null, "psContactorBLVDState" ),
                    new Wrappers.ContentItem( null, "psContactorL1VDState" ),
                    new Wrappers.ContentItem( null, "psContactorL2VDState" ),
                    new Wrappers.ContentItem( null, "psContactorL3VDState" ),

                    new Wrappers.ContentItem( "psContactorSycnro", "", Wrappers.RowTypes.CHECHBOX, "num" ),
                    new Wrappers.ContentItem( "psContactorBLVDState", "", Wrappers.RowTypes.CHECHBOX, "num" ),
                    new Wrappers.ContentItem( "psContactorL1VDState", "", Wrappers.RowTypes.CHECHBOX, "num" ),
                    new Wrappers.ContentItem( "psContactorL2VDState", "", Wrappers.RowTypes.CHECHBOX, "num" ),
                    new Wrappers.ContentItem( "psContactorL3VDState", "", Wrappers.RowTypes.CHECHBOX, "num" )
                ]
            }
        }
    }
}
