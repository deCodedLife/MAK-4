import QtQuick
import QtQuick.Layouts

import "../Globals"

Row
{
    property int lineWidth: 5
    property int linesCount: 2

    spacing: lineWidth
    leftPadding: lineWidth

    height: 1

    Repeater {
        model: linesCount
        delegate: Rectangle {
            width: lineWidth
            height: 1
            color: "#F3F3F3"
        }
    }

    function calculate() {
        linesCount = ( width / lineWidth ) / 2
        if ( linesCount % 2 == 0 ) leftPadding = lineWidth / 2
    }

    Component.onCompleted: calculate()
    onWidthChanged: calculate()
}
