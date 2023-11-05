import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import "../Components"
import "../Globals"

Page
{
    contentHeight: content.implicitHeight + 20

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

        TableComponent {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.maximumWidth: 1200

            headers: [
                { "title": "Температура 1, °C", "expand": false },
                { "title": "Средняя Температура, °C", "expand": false },
                { "title": "Состояние Датчика 1", "expand": false },
                { "title": "Температура 2, °C", "expand": false },
                { "title": "Состояние Датчика 2", "expand": false }
            ]

            content: [
                { type: 4, field: "psTemperature1" },
                { type: 4, field: "psMeanTemperature1" },
                addWrapper( { type: 4, field: "psTemperature1Status" }, value => {
                    if ( parseInt( value ) === 0 ) return "Норма"
                    if ( parseInt( value ) === 1 ) return "Ошибка"
                    return value
                } ),
                { type: 4, field: "psTemperature2" },
                addWrapper( { type: 4, field: "psTemperature2Status" }, value => {
                    if ( parseInt( value ) === 0 ) return "Норма"
                    if ( parseInt( value ) === 1 ) return "Пониженная"
                    if ( parseInt( value ) === 2 ) return "Повышенная"
                    if ( parseInt( value ) === 3 ) return "Ошибка"
                    if ( parseInt( value ) === 4 ) return "Отключено"
                    return value
                } )
            ]
        }
    }
}
