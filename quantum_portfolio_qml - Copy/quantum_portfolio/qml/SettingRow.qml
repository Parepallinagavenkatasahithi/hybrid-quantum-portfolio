import QtQuick
import QtQuick.Layouts

// SettingRow — label + right-side control
Item {
    property string label: ""
    default property alias control: controlSlot.data

    width: parent.width
    height: 44

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: label
        font.pixelSize: 12
        color: "#8892b0"
        width: 200
    }

    Item {
        id: controlSlot
        anchors.left: parent.left
        anchors.leftMargin: 210
        anchors.right: parent.right
        height: parent.height
    }
}
