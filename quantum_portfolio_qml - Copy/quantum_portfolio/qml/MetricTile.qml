import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property string label: ""
    property string value: "--"
    property string unit: ""
    property color accentColor: "#00d4ff"
    property string trend: ""

    height: 90
    color: "#0f1018"
    border.color: "#2a2d45"
    border.width: 1
    radius: 12

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 4

        Text {
            text: root.label
            font.pixelSize: 10
            font.letterSpacing: 1.5
            color: "#4a5068"
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                text: root.value
                font.pixelSize: 22
                font.weight: Font.Bold
                color: root.accentColor
                Layout.alignment: Qt.AlignBottom
            }

            Text {
                visible: root.unit !== ""
                text: root.unit
                font.pixelSize: 12
                color: "#4a5068"
                Layout.alignment: Qt.AlignBottom
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                visible: root.trend !== ""
                text: root.trend === "up" ? "^" : "v"
                font.pixelSize: 11
                color: root.trend === "up" ? "#00e5a0" : "#ff5555"
                Layout.alignment: Qt.AlignBottom
            }
        }
    }
}
