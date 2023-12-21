import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl

import QtQuick.Dialogs

import "Globals"
import "Components"

ApplicationWindow
{
    width: 1024
    height: 860

    minimumWidth: 800
    minimumHeight: 400

    visible: true
    title: "MAK-4 0.1.7 beta " + (Globals.windowSuffix != "" ? `[${Globals.windowSuffix}]` : "")

    color: Globals.accentColor
    Material.theme: Material.Light
    Material.accent: Material.Blue
    Material.containerStyle: Material.Filled

    FileDialog {
        id: fileDialog
        nameFilters: ["MAK-4 settings files (*.m4ss)"]
        fileMode: FileDialog.OpenFile
        onAccepted: {
            let file = selectedFile.toString()
            if ( Qt.platform.os === "windows" ) file = file.split( "file:///" )[ 1 ]
            else file = file.split( "file://" )[ 1 ]

            if ( fileMode == FileDialog.OpenFile ) ConfigManager.openFile( file )
            else ConfigManager.saveFile( file )

            SNMP.sendConfigsChangedEvent()
        }
        Component.onCompleted: LeftMenuG.fileDialog = fileDialog
    }

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
