// PageHeader.qml
import QtQuick
import QtQuick.Layouts

Item {
    property string title: ""
    property string subtitle: ""
    property string badgeText: ""
    property color  badgeColor: "#00d4ff"

    width: parent.width
    height: 64

    Column {
        spacing: 4
        Text {
            text: title
            font.pixelSize: 26
            font.weight: Font.Bold
            color: "#e8eaf6"
        }
        Text {
            text: subtitle
            font.pixelSize: 12
            color: "#4a5068"
        }
    }

    Rectangle {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: badgeLabel.width + 24
        height: 30
        radius: 15
        color: Qt.rgba(badgeColor.r, badgeColor.g, badgeColor.b, 0.12)
        border.color: badgeColor
        border.width: 1

        Text {
            id: badgeLabel
            anchors.centerIn: parent
            text: badgeText
            font.pixelSize: 10
            font.letterSpacing: 1.5
            font.weight: Font.DemiBold
            color: badgeColor
        }
    }
}
