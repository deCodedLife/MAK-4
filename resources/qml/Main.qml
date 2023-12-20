import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl

import "Globals"
import "Components"

ApplicationWindow
{
    width: 1024
    height: 860

    minimumWidth: 800
    minimumHeight: 400

    visible: true
    title: "MAK-4"

    color: Globals.accentColor
    Material.theme: Material.Light
    Material.accent: Material.Blue
    Material.containerStyle: Material.Filled

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        StatusText {
            Layout.fillWidth: true
            Layout.leftMargin: 25
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            LeftMenu {
                Layout.fillHeight: true
                Layout.preferredWidth: 200
            }

            PageLoader {
                id: pageLoader
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent

        Notifications {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Layout.maximumWidth: 350
            Layout.alignment: Qt.AlignRight | Qt.AlignBottom
        }
    }
}
