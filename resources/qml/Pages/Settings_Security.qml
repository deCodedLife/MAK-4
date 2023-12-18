import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import "../Components"
import "../Globals"
import "../wrappers.mjs" as Wrappers

Page
{
    property var configuration: ConfigManager.get()[ "security" ]
    contentHeight: pageContent.implicitHeight + 20
    property list<string> changed: []

    actionButtonIcon: "qrc:/images/icons/save.svg"
    actionButtonTitle: "Записать"

    onActionButtonTriggered: {
        let changes = {}
        let keys = Object.keys( configuration )

        for ( let i = 0; i < keys.length; i++ )
        {
            let currentConfig = configuration[ keys[i] ]
            let isChanged = changed.includes( keys[i] )
            if ( isChanged ) {
                changes[ keys[ i ] ] = currentConfig
                changed.splice( i, 1 )
            }
        }

        SNMP.setMultiple( changes )
    }

    function updateConfig( field, value ) {
        let newConfig = ConfigManager.current
        configuration[ field ][ "value" ] = Wrappers.getFieldValue( configuration[ field ], value )
        changed.push( field )
        newConfig[ "security" ] = configuration
        ConfigManager.current = newConfig
    }

    Connections
    {
        target: SNMP

        function onSettingsChanged()
        {
            configuration = ConfigManager.get()[ "security" ]
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

        CardComponent {
            Layout.maximumWidth: 1200
            Layout.alignment: Qt.AlignHCenter| Qt.AlignTop
            Layout.fillWidth: true

            fields: [
                configuration[ "stMonitoringPassword" ],
                configuration[ "stEnableRemouteChangeSetting" ],
                configuration[ "stEnableRemouteUpdateFirmware" ]
            ]

            onFieldUpdated: ( field, value ) => updateConfig( field, value )
        }
    }
}
