import QtQuick

Row {
    property string label: ""
    property string value: "--"
    property color  col: "#8892b0"
    width: parent.width
    height: 26
    spacing: 8

    Text {
        width: 70; height: parent.height
        text: label
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 11; color: "#4a5068"
    }
    Text {
        height: parent.height
        text: value
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 12; font.weight: Font.DemiBold
        color: col
    }
}
