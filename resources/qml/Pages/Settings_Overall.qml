import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import "../Components"
import "../Globals"
import "../wrappers.mjs" as Wrappers

Page
{
    property var configuration: ConfigManager.get()[ "overall" ]
    contentHeight: pageContent.implicitHeight + 20

    actionButtonIcon: "qrc:/images/icons/save.svg"
    actionButtonTitle: "Записать"

    onActionButtonTriggered: SNMP.setMultiple( configuration )

    function updateConfig( field, value ) {
        let newConfig = ConfigManager.current
        configuration[ field ][ "value" ] = Wrappers.getFieldValue( configuration[ field ], value )
        newConfig[ "overall" ] = configuration
        ConfigManager.current = newConfig
    }

    Connections
    {
        target: SNMP

        function onSettingsChanged()
        {
            configuration = ConfigManager.get()[ "overall" ]
        }
    }

    ColumnLayout {
        id: pageContent

        anchors.fill: parent
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        anchors.leftMargin: 20
        anchors.rightMargin: 20

        spacing: 10

        RowLayout {
            Layout.maximumWidth: 1200
            Layout.alignment: Qt.AlignHCenter| Qt.AlignTop
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: 10

            CardComponent {
                fields: {
                    let _fields = []

                    let timezone = configuration[ "psTimeZone" ]
                    timezone[ "wrapper" ] = Wrappers.divideByFour
                    _fields.push( timezone )

                    _fields.push( configuration[ "psBuzzerEnable" ] )
                    return _fields
                }
                onFieldUpdated: ( field, value ) => updateConfig( field, value )
            }

            Item{ Layout.fillWidth: true }
        }
    }
}
