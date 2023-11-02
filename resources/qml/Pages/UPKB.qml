import QtQuick
import QtQuick.Layouts

import "../Components"
import "../Globals"

Page
{
    id: root

    contentHeight: content.implicitHeight + 20

    function addWrapper( config, wrapper ) {
        config[ "wrapper" ] = wrapper
        return config
    }

    property list<var> groupsFields: []
    property list<var> headers: [
        { "title": "Номер", "expand": false },
        { "title": "U, В", "expand": false },
        { "title": "t, °C", "expand": false },
        { "title": "Состояние", "expand": true }
    ]


    Component.onCompleted: {
        let groups = SNMP.getBulk( "psBlockGroup" )
        let numbers = SNMP.getBulk( "psBlockNumber" )
        let voltage = SNMP.getBulk( "psBlockVoltage" )
        let temperature = SNMP.getBulk( "psBlockTemperature" )
        let statuses = SNMP.getBulk( "psBlockStatus" )

        let groupIndexCount = [ 0, 0, 0, 0]

        for ( let index = 0; index < groups.length; index++ ) {
            if ( parseInt( groups[ index ] ) === 1 ) groupIndexCount[0]++
            if ( parseInt( groups[ index ] ) === 2 ) groupIndexCount[1]++
            if ( parseInt( groups[ index ] ) === 3 ) groupIndexCount[2]++
            if ( parseInt( groups[ index ] ) === 4 ) groupIndexCount[3]++
        }

        for ( let groupIndex = 0; groupIndex < 4; groupIndex++ ) {
            let itemsCount = groupIndexCount[ groupIndex ]
            let fields = []
            for ( let index2 = 0; index2 < itemsCount; index2++ ) {
                let currentValue = index2 + (groupIndex * itemsCount)
                fields.push( { type: 5, value: numbers[ currentValue ] } )
                fields.push( { type: 5, value: parseFloat( voltage[ currentValue ] ) / 100 } )
                fields.push( { type: 5, value: parseFloat( temperature[ currentValue ] ) / 100 } )
                fields.push( addWrapper( { type: 5, value: statuses[ currentValue ] }, value => {
                    if ( parseInt(value) === 0 ) return "Норма"
                    if ( parseInt(value) === 1 ) return "Пониженное напряжение"
                    if ( parseInt(value) === 2 ) return "Повышенное напряжение"
                    if ( parseInt(value) === 3 ) return "Перегрев"
                    if ( parseInt(value) === 4 ) return "Ошибка"
                    return value
                } ) )
            }
            groupsFields.push( fields )
        }
    }

    ColumnLayout {
        id: content

        anchors.fill: parent
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        anchors.leftMargin: 20
        anchors.rightMargin: 20

        RowLayout {

            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.maximumWidth: 1200
            spacing: 10

            Repeater {

                model: groupsFields.length

                TableComponent {
                    Layout.alignment: Qt.AlignTop
                    header: "УПКБ" + (index + 1)

                    headers: root.headers
                    content: groupsFields[ index ]
                }
            }
        }
    }
}
