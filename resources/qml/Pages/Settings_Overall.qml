import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import "../Components"
import "../Globals"

Page
{
    property var configuration: ConfigManager.get()[ "overall" ]

    contentHeight: pageContent.implicitHeight + 20

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
                fields: [
                    configuration[ "psTimeZone" ],
                    configuration[ "psBuzzerEnable" ]
                ]
                onFieldUpdated: ( field, value ) => {
                    let newConfig = ConfigManager.current
                    console.log( field, value )
                    configuration[ field ][ "value" ] = value
                    newConfig[ "overall" ] = configuration
                    ConfigManager.current = newConfig
                }
            }

            Item{}
        }
    }
}
