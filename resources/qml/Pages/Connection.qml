import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import "../Components"
import "../Globals"

Page
{
    property var configuration: Config.current
    property string host: configuration[ "host" ].split( ":" )[ 1 ]
    property string port: configuration[ "host" ].split( ":" )[ 2 ]
    property string delay: configuration[ "updateDelay" ]
    property int snmp: configuration[ "snmpVersion" ]

    property string v2_read: configuration[ "v2_read" ]
    property string v2_write: configuration[ "v2_write" ]

    property string user: configuration[ "user" ]
    property string authMethod: configuration[ "authMethod" ]
    property string authPassword: configuration[ "authPassword" ]
    property string authProtocol: configuration[ "authProtocol" ]
    property string privProtocol: configuration[ "privProtocol" ]
    property string privPassword: configuration[ "privPassword" ]


    function updateConfiguration() {
        configuration[ "host" ] = `udp:${host}:${port}`
        configuration[ "updateDelay" ] = parseInt( delay )
        console.log( JSON.stringify( configuration ) )
    }

    onHostChanged: updateConfiguration()
    onPortChanged: updateConfiguration()
    onDelayChanged: updateConfiguration()

    Flickable {
        anchors.fill: parent
        interactive: height < contentHeight
        contentHeight: pageContent.implicitHeight + 40
        boundsMovement: Flickable.StopAtBounds

        ColumnLayout {
            id: pageContent

            anchors.fill: parent
            anchors.margins: {
                top: 10
                bottom: 10
                left: 20
                right: 20
            }
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                height: implicitHeight
                spacing: 10
                Layout.maximumWidth: 1200
                Layout.alignment: Qt.AlignHCenter

                CardComponent
                {
                    Layout.alignment: Qt.AlignTop
                    Layout.fillWidth: true
                    height: cardLayout.implicitHeight + 40

                    ColumnLayout {
                        id: cardLayout
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 10

                        CustomField {
                            Layout.fillWidth: true
                            placeholderText: "IP адрес"
                            value: host
                            onValueChanged: host = text
                        }

                        CustomField {
                            Layout.fillWidth: true
                            placeholderText: "Порт"
                            text: port
                            onValueChanged: port = text
                        }

                        CustomDropDown {
                            Layout.fillWidth: true
                            model: [
                                "snmpV2",
                                "snmpV3"
                            ]
                            preSelected: snmp
                        }

                        CustomField {
                            Layout.fillWidth: true
                            placeholderText: "Период опроса"
                            text: delay
                            onValueChanged: delay = text
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Button {
                                Layout.fillWidth: true
                                text: "Соединить"
                                highlighted: true
                                Material.accent: Globals.accentColor
                                onClicked: console.log( "try" )
                            }

                            Button {
                                Layout.fillWidth: true
                                text: "Отключить"
                                highlighted: true
                                Material.accent: Globals.errorColor
                                onClicked: console.log( "fetch" )
                            }
                        }
                    }
                }

                Item{ Layout.fillWidth: true }

            }

            RowLayout {
                Layout.fillWidth: true
                height: implicitHeight
                spacing: 10
                Layout.maximumWidth: 1200
                Layout.alignment: Qt.AlignHCenter

                CardComponent
                {
                    Layout.fillWidth: true
                    height: cardLayout2.implicitHeight + 40
                    Layout.alignment: Qt.AlignTop

                    ColumnLayout {
                        id: cardLayout2
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 10

                        CustomField {
                            Layout.fillWidth: true
                            placeholderText: "Для чтения"
                            value: host
                            onValueChanged: host = text
                        }

                        CustomField {
                            Layout.fillWidth: true
                            placeholderText: "Для записи"
                            text: port
                            onValueChanged: port = text
                        }

                    }
                }

                CardComponent
                {
                    Layout.alignment: Qt.AlignTop
                    Layout.fillWidth: true
                    height: cardLayout3.implicitHeight + 40

                    ColumnLayout {
                        id: cardLayout3
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 10

                        CustomField {
                            Layout.fillWidth: true
                            placeholderText: "Имя"
                            value: user
                            onValueChanged: user = text
                        }

                        CustomField {
                            Layout.fillWidth: true
                            placeholderText: "Уровень"
                            text: authMethod
                            onValueChanged: authMethod = text
                        }

                        CustomField {
                            Layout.fillWidth: true
                            placeholderText: "Пароль аутентификации"
                            text: authPassword
                            onValueChanged: authPassword = text
                        }

                        CustomField {
                            Layout.fillWidth: true
                            placeholderText: "Протокол аутентификации"
                            text: authProtocol
                            onValueChanged: authProtocol = text
                        }

                        CustomField {
                            Layout.fillWidth: true
                            placeholderText: "Пароль приватности"
                            text: privProtocol
                            onValueChanged: privProtocol = text
                        }

                        CustomField {
                            Layout.fillWidth: true
                            placeholderText: "Протокол приватноси"
                            text: privPassword
                            onValueChanged: privPassword = text
                        }

                    }
                }

            }
            Item{ Layout.fillHeight: true }
        }
    }
}
