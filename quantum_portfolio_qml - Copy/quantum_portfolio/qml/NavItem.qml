import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property string icon: ""
    property string label: ""
    property bool active: false
    signal clicked()

    height: 44
    color: active ? "#1e2030" : (hov.containsMouse ? "#161822" : "transparent")
    radius: 0

    Behavior on color { ColorAnimation { duration: 120 } }

    // Left accent bar
    Rectangle {
        width: 3
        height: active ? 28 : 0
        anchors.verticalCenter: parent.verticalCenter
        radius: 2
        color: "#00d4ff"
        Behavior on height { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 22
        anchors.rightMargin: 12
        spacing: 12

        Text {
            text: root.icon
            font.pixelSize: 15
            color: root.active ? "#00d4ff" : (hov.containsMouse ? "#8892b0" : "#4a5068")
            Behavior on color { ColorAnimation { duration: 120 } }
        }

        Text {
            Layout.fillWidth: true
            text: root.label
            font.pixelSize: 12
            font.weight: root.active ? Font.DemiBold : Font.Normal
            font.letterSpacing: 0.5
            color: root.active ? "#e8eaf6" : (hov.containsMouse ? "#8892b0" : "#4a5068")
            Behavior on color { ColorAnimation { duration: 120 } }
        }
    }

    MouseArea {
        id: hov
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
