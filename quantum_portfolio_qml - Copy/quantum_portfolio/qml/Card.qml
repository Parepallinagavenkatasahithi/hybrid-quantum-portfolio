import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    property string title: ""
    property alias content: contentLoader.sourceComponent
    default property alias children: innerContent.data

    color: "#0f1018"
    border.color: "#2a2d45"
    border.width: 1
    radius: 12

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Text {
            visible: root.title !== ""
            text: root.title
            font.pixelSize: 12
            font.weight: Font.DemiBold
            font.letterSpacing: 1.5
            color: "#4a5068"
            textTransform: Text.UppercaseText
        }

        Item {
            id: innerContent
            width: parent.width
            height: parent.height - (root.title !== "" ? 40 : 0)
        }
    }
}
