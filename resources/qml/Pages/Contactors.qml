import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import "../Components"
import "../Globals"

Page
{
    id: root
    contentHeight: content.implicitHeight

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

            CustomSwitch {
                id: handControl
                text: "Ручное управление"
            }

            TableComponent {
                id: table
                Layout.alignment: Qt.AlignTop
                enabled: handControl.toggled

                headers: [
                    { "title": "Контактор", "expand": true },
                    { "title": "Состояние", "expand": true },
                ]

                content: [
                    { type: 5, value: "psContactorSycnro" },
                    addWrapper( { type: 6, field: "psContactorSycnro" }, value => { SNMP.setOID( "psContactorSycnro", value ) } ),
                    { type: 5, value: "psContactorBLVDState" },
                    addWrapper( { type: 6, field: "psContactorBLVDState" }, value => { SNMP.setOID( "psContactorBLVDState", value ) } ),
                    { type: 5, value: "psContactorL1VDState" },
                    addWrapper( { type: 6, field: "psContactorL1VDState" }, value => { SNMP.setOID( "psContactorL1VDState", value ) } ),
                    { type: 5, value: "psContactorL2VDState" },
                    addWrapper( { type: 6, field: "psContactorL2VDState" }, value => { SNMP.setOID( "psContactorL2VDState", value ) } ),
                    { type: 5, value: "psContactorL3VDState" },
                    addWrapper( { type: 6, field: "psContactorL3VDState" }, value => { SNMP.setOID( "psContactorL3VDState", value ) } ),
                ]
            }
        }
    }
}
