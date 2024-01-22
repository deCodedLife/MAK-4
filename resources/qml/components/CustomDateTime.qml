import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import "../Globals"

Item
{
    id: root

    property string placeholder: parent.placeholder ?? ""
    property date content: {
        if ( !parent.value ) return new Date( Date.now() )

        let parsedDate = new Date()
        let splited = parent.value.split('')
        parsedDate.setFullYear( parseInt( splited.slice( 4, 8 ).join('') ) )
        parsedDate.setMonth( parseInt( splited.slice( 2, 4 ).join('') ) - 1 )
        parsedDate.setDate( parseInt( splited.slice( 0, 2 ).join('') ) )

        parsedDate.setHours( parseInt( splited.slice( 8, 10 ).join('') ) )
        parsedDate.setMinutes( parseInt( splited.slice( 10, 12 ).join('') ) )
        parsedDate.setSeconds( parseInt( splited.slice( 12, 14 ).join('') ) )


        return parsedDate
    }

    property string day: {
        let day = content.getDate()
        return day < 10 ? `0${day}` : day
    }
    property string month: {
        let month = content.getMonth() + 1
        return month < 10 ? `0${month}` : month
    }
    property string year: content.getFullYear()

    property string hours: {
        let hours = content.getHours()
        return hours < 10 ? `0${hours}` : hours
    }
    property string minutes: {
        let minutes = content.getMinutes()
        return minutes < 10 ? `0${minutes}` : minutes
    }
    property string seconds: {
        let seconds = content.getSeconds()
        return seconds < 10 ? `0${seconds}` : seconds
    }

    function changeContent() {
        console.log( `${day}${month}${year}${hours}${minutes}${seconds}` )
        parent.updateField( `${day}${month}${year}${hours}${minutes}${seconds}` )
    }


    Layout.fillWidth: true
    height: 64

    RowLayout {
        id: dateTimeWrapper
        anchors.fill: parent
        spacing: 10


        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true

            color: Material.textFieldFilledContainerColor
            radius: 5

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 5

                Text {
                    id: placeholderText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    enabled: placeholder !== ""
                    visible: placeholder !== ""
                    text: placeholder
                    font.pointSize: Globals.h6 - 1
                }

                Text {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignVCenter
                    font.pointSize: Globals.h5
                    text: `${day}-${month}-${year}`
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: datePopup.open()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true

            color: Material.textFieldFilledContainerColor
            radius: 5

            Text {
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: Globals.h5
                text: `${hours}:${minutes}:${seconds}`
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: timePopup.open()
            }
        }
    }



    Popup {
        id: datePopup

        property bool contains: root.width > 320
        width: 350
        height: 420
        closePolicy: Popup.CloseOnPressOutside


        anchors.centerIn: contains ? null : Globals.rootObject
        parent: contains ? dateTimeWrapper : Globals.rootObject
        modal: !contains

        contentItem: Rectangle {
            anchors.fill: parent

            color: "white"
            radius: 5
            border.color: Globals.grayScale
            border.width: 1

            ColumnLayout {
                id: datePicker

                anchors.fill: parent
                anchors.margins: 5

                property var selectedTime: selectedDate.getTime()
                property date selectedDate: new Date( Date.parse( `${root.year}-${root.month}-${root.day}` ) )
                property alias month: picker.month
                property alias year: picker.year
                property alias locale: picker.locale

                onSelectedDateChanged: {
                    content.setDate( selectedDate.getDate() )
                    content.setFullYear( selectedDate.getFullYear() )
                    content.setMonth( selectedDate.getMonth() )
                }

                RowLayout {
                    spacing: 10

                    Button {
                        icon.source: LeftMenuG.iconsLocation + "go_back.svg"
                        flat: true
                        Material.elevation: 0
                        property Rectangle back: background

                        bottomInset: 0
                        topInset: 0
                        leftInset: 0
                        rightInset: 0

                        leftPadding: 5
                        rightPadding: 5

                        horizontalPadding: 0
                        verticalPadding: 0

                        Component.onCompleted: back.implicitWidth = 24
                        onClicked: {
                            if ( datePicker.month === 0 ) {
                                datePicker.month = 11
                                datePicker.year -= 1
                                return
                            }

                            datePicker.month -= 1
                        }
                    }

                    Text {
                        property list<string> monthNames: [ "Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь" ]
                        Layout.preferredWidth: 50
                        text: monthNames[ datePicker.month ]
                        horizontalAlignment: Text.AlignHCenter

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: swiper.setCurrentIndex(2)
                        }
                    }

                    Button {
                        icon.source: LeftMenuG.iconsLocation + "go_forward.svg"
                        flat: true
                        Material.elevation: 0
                        property Rectangle back: background

                        bottomInset: 0
                        topInset: 0
                        leftInset: 0
                        rightInset: 0

                        leftPadding: 5
                        rightPadding: 5

                        horizontalPadding: 0
                        verticalPadding: 0

                        Component.onCompleted: back.implicitWidth = 24
                        onClicked: {
                            if ( datePicker.month === 11 ) {
                                datePicker.month = 0
                                datePicker.year += 1
                                return
                            }

                            datePicker.month += 1
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Button {
                        icon.source: LeftMenuG.iconsLocation + "go_back.svg"
                        flat: true
                        Material.elevation: 0
                        property Rectangle back: background

                        bottomInset: 0
                        topInset: 0
                        leftInset: 0
                        rightInset: 0

                        leftPadding: 5
                        rightPadding: 5

                        horizontalPadding: 0
                        verticalPadding: 0

                        Component.onCompleted: back.implicitWidth = 24
                        onClicked: datePicker.year -= 1
                    }

                    Text {
                        text: datePicker.year
                    }

                    Button {
                        icon.source: LeftMenuG.iconsLocation + "go_forward.svg"
                        flat: true
                        Material.elevation: 0
                        property Rectangle back: background

                        bottomInset: 0
                        topInset: 0
                        leftInset: 0
                        rightInset: 0

                        leftPadding: 5
                        rightPadding: 5

                        horizontalPadding: 0
                        verticalPadding: 0

                        Component.onCompleted: back.implicitWidth = 24
                        onClicked: datePicker.year += 1
                    }
                }

                SwipeView {

                    id: swiper

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    currentIndex: 1

                    Item {

                        ListView {

                            width: parent.width
                            height: parent.height

                            clip: true
                            boundsMovement: Flickable.StopAtBounds

                            model: [ "Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь" ]
                            delegate: Button {
                                width: parent.width
                                text: modelData
                                flat: true

                                onClicked: {
                                    datePicker.month = index
                                    swiper.setCurrentIndex(0)
                                }
                            }

                        }

                    }

                    Item {
                        id: pickerWrapper

                        ColumnLayout {

                            width: parent.width
                            height: parent.height

                            DayOfWeekRow {
                                id: weeks

                                locale: picker.locale
                                Layout.fillWidth: true
                                font.bold: true

                                delegate: Text {
                                    text: shortName
                                    font: weeks.font
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    color: Material.primaryTextColor
                                    required property string shortName
                                }
                            }


                            MonthGrid {
                                id: picker
                                locale: Qt.locale("ru_RU")
                                Layout.fillWidth: true
                                Layout.preferredHeight: 300
                                font.bold: true

                                year: datePicker.selectedDate.getFullYear()
                                month: datePicker.selectedDate.getMonth()

                                delegate: Text {
                                    property MonthGrid control: picker
                                    property bool isCurrentItem: model.date.getTime() === datePicker.selectedTime

                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    text: model.day
                                    font: control.font
                                    color: isCurrentItem ? "white" : Material.primaryTextColor
                                    opacity: model.month === control.month ? 1 : 0.5

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: height / 2
                                        visible: isCurrentItem
                                        color: Material.accentColor
                                        z: -2
                                    }
                                }

                                onClicked: (date) => {
                                    datePicker.selectedTime = date.getTime()
                                    datePicker.selectedDate = new Date( datePicker.selectedTime )
                                    changeContent()
                                }
                            }

                        }
                    }

                    Item {

                        ListView {

                            width: parent.width
                            height: parent.height

                            clip: true
                            boundsMovement: Flickable.StopAtBounds

                            model: [ "Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь" ]
                            delegate: Button {
                                width: parent.width
                                text: modelData
                                flat: true

                                onClicked: {
                                    datePicker.month = index
                                    swiper.setCurrentIndex(1)
                                }
                            }

                        }

                    }

                }
            }
        }
    }

    Popup {
        id: timePopup

        width: 350
        height: timeWrapper.implicitHeight + 20
        closePolicy: Popup.CloseOnPressOutside

        contentItem: Rectangle {
            anchors.fill: parent

            color: "white"
            radius: 5
            border.color: Globals.grayScale
            border.width: 1

            ColumnLayout {
                id: timeWrapper
                anchors.fill: parent
                anchors.margins: 5

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10

                    TextField {
                        Layout.fillWidth: true
                        id: firstTime
                        placeholderText: "Часы"
                        text: hours
                        validator: IntValidator { bottom: 0; top: 24 }
                        color: acceptableInput ? Globals.grayAccent : Globals.errorColor
                        implicitWidth: 74
                        horizontalAlignment: TextField.AlignHCenter
                        property int value: 0
                        onTextChanged: {
                            if ( !acceptableInput ) return
                            value = parseInt( text )
                        }
                        Component.onCompleted: {
                            value = parseInt( text )
                            text = value < 10 ? `0${value}` : value
                        }
                    }

                    Text {
                        text: ":"
                        font.pointSize: Globals.h2
                    }

                    TextField {
                        Layout.fillWidth: true
                        id: secondTime
                        placeholderText: "Минуты"
                        text: minutes
                        validator: IntValidator { bottom: 0; top: 60 }
                        color: acceptableInput ? Globals.grayAccent : Globals.errorColor
                        implicitWidth: 74
                        horizontalAlignment: TextField.AlignHCenter
                        property int value: 0
                        onTextChanged: {
                            if ( !acceptableInput ) return
                            value = parseInt( text )
                        }
                        Component.onCompleted: value = parseInt( text )
                    }

                    Text {
                        text: ":"
                        font.pointSize: Globals.h2
                    }

                    TextField {
                        Layout.fillWidth: true
                        id: thirdTime
                        text: seconds
                        placeholderText: "Секунды"
                        validator: IntValidator { bottom: 0; top: 60 }
                        color: acceptableInput ? Globals.grayAccent : Globals.errorColor
                        implicitWidth: 74
                        horizontalAlignment: TextField.AlignHCenter
                        property int value: 0
                        onTextChanged: {
                            if ( !acceptableInput ) return
                            value = parseInt( text )
                        }
                        Component.onCompleted: value = parseInt( text )
                    }
                }

                RowLayout {

                    Item { Layout.fillWidth: true }

                    Button {
                        text: "Отмена"
                        flat: true
                        onClicked: timePopup.close()
                    }

                    Button {
                        text: "Ok"
                        flat: true
                        onClicked: {
                            content.setHours( firstTime.value )
                            content.setMinutes( secondTime.value )
                            content.setSeconds( thirdTime.value )

                            changeContent()
                            timePopup.close()
                        }
                    }
                }
            }
        }
    }
}
