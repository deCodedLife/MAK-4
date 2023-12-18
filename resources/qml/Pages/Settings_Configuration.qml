import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import "../Components"
import "../Globals"
import "../wrappers.mjs" as Wrappers

Page
{
    property var configuration: ConfigManager.get()[ "configuration" ]
    contentHeight: pageContent.implicitHeight + 20

    actionButtonIcon: "qrc:/images/icons/save.svg"
    actionButtonTitle: "Записать"

    onActionButtonTriggered: SNMP.setMultiple( configuration )

    function updateConfig( field, value ) {
        let newConfig = ConfigManager.current
        configuration[ field ][ "value" ] = Wrappers.getFieldValue( configuration[ field ], value )
        newConfig[ "configuration" ] = configuration
        ConfigManager.current = newConfig
    }

    Connections
    {
        target: SNMP

        function onSettingsChanged()
        {
            configuration = ConfigManager.get()[ "configuration" ]
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
                configuration[ "stBatteryGroupsNumber" ],
                configuration[ "stLoadFusesNumber" ],
                configuration[ "stLVDsNumber" ],
                configuration[ "stVBVNumber" ]
            ]
            onFieldUpdated: ( field, value ) => updateConfig( field, value )
        }
    }
}
