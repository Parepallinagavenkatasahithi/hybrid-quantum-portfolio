import QtQuick
import QtQuick.Controls

Row {
    property real from: 0
    property real to: 100
    property real stepSize: 1
    property real value: 0
    property string displayValue: value.toString()
    signal sliderValueChanged(real v)

    spacing: 14
    anchors.verticalCenter: parent ? parent.verticalCenter : undefined

    Slider {
        id: sl
        from: parent.from
        to: parent.to
        stepSize: parent.stepSize
        value: parent.value
        width: 280
        anchors.verticalCenter: parent.verticalCenter

        onValueChanged: parent.sliderValueChanged(value)

        background: Rectangle {
            x: sl.leftPadding; y: sl.topPadding + sl.availableHeight / 2 - height / 2
            width: sl.availableWidth; height: 4; radius: 2
            color: "#1e2030"

            Rectangle {
                width: sl.visualPosition * parent.width
                height: parent.height; radius: parent.radius
                color: "#00d4ff"
            }
        }

        handle: Rectangle {
            x: sl.leftPadding + sl.visualPosition * (sl.availableWidth - width)
            y: sl.topPadding + sl.availableHeight / 2 - height / 2
            width: 14; height: 14; radius: 7
            color: sl.pressed ? "#00b8dd" : "#00d4ff"
            border.color: "#08090e"; border.width: 2

            Behavior on color { ColorAnimation { duration: 100 } }
        }
    }

    Rectangle {
        width: 72; height: 32
        color: "#161822"
        border.color: "#2a2d45"
        radius: 6
        anchors.verticalCenter: parent.verticalCenter

        Text {
            anchors.centerIn: parent
            text: displayValue
            font.pixelSize: 12
            font.weight: Font.DemiBold
            color: "#00d4ff"
        }
    }
}
