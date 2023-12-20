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

    property var contactorsConfigs: ConfigManager.get()[ "blvd" ]

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

            Item {
                Layout.fillWidth: true
                height: 38

                function updateField( value ) {
                    let newConfig = ConfigManager.current
                    let field = contactorsConfigs[ handControl.switchOID ]
                    contactorsConfigs[ handControl.switchOID ][ "value" ] = Wrappers.getFieldValue( field, value )
                    newConfig[ "blvd" ] = contactorsConfigs
                    ConfigManager.current = newConfig
                    SNMP.setOID( handControl.switchOID, Wrappers.getFieldValue( field, value ) )
                }

                CustomSwitch {
                    property string switchOID: "stContactorControl"

                    id: handControl
                    toggled: contactorsConfigs[ switchOID ] === 1
                    text: "Ручное управление"                    

                    Connections {
                        target: SNMP
                        function onGotRowsContent( root: string, data: object ) {
                            if ( root !== handControl.switchOID ) return
                            handControl.toggled = data[ handControl.switchOID ][ "num" ] === 1
                        }
                    }
                    Component.onCompleted: SNMP.getOIDs( switchOID, [ switchOID + ".0" ] )
                }
            }

            FieldsTable {
                id: table
                Layout.alignment: Qt.AlignTop
                enabled: handControl.toggled
                activeColumns: 1

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
                    new Wrappers.ContentItem( null, "Батарейный (BLVD)" ),
                    new Wrappers.ContentItem( null, "Нагрузочный 1 (LLVD 1)" ),
                    new Wrappers.ContentItem( null, "Нагрузочный 2 (LLVD 2)" ),
                    new Wrappers.ContentItem( null, "Нагрузочный 2 (LLVD 3)" ),

                    new Wrappers.ContentItem( "psContactorBLVDState", "", Wrappers.RowTypes.SWITCH, "num" ),
                    new Wrappers.ContentItem( "psContactorL1VDState", "", Wrappers.RowTypes.SWITCH, "num" ),
                    new Wrappers.ContentItem( "psContactorL2VDState", "", Wrappers.RowTypes.SWITCH, "num" ),
                    new Wrappers.ContentItem( "psContactorL3VDState", "", Wrappers.RowTypes.SWITCH, "num" )
                ]
            }

            Button
            {
                highlighted: true
                Material.accent: Globals.accentColor
                text: "Синхронизировать положение"
                font.pointSize: Globals.h6
                onClicked: SNMP.setOID( "psContactorSycnro", 1 )
            }
        }
    }
}
