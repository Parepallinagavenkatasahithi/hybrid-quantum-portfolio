import QtQuick
import QtQuick.Controls

Item {
    id: root
    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottomMargin: 32
    z: 999

    property bool isError: false

    function show(msg, error) {
        isError = error
        toastText.text = msg
        showAnim.restart()
    }

    Rectangle {
        id: toastRect
        width: toastText.width + 48
        height: 44
        radius: 22
        anchors.horizontalCenter: parent.horizontalCenter
        color: root.isError ? "#2a0a0a" : "#0a1a14"
        border.color: root.isError ? "#ff5555" : "#00e5a0"
        border.width: 1
        opacity: 0

        Row {
            anchors.centerIn: parent
            spacing: 10

            Text {
                text: root.isError ? "✕" : "✓"
                font.pixelSize: 13
                color: root.isError ? "#ff5555" : "#00e5a0"
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                id: toastText
                font.pixelSize: 13
                color: "#e8eaf6"
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        SequentialAnimation {
            id: showAnim
            NumberAnimation { target: toastRect; property: "opacity"; to: 1; duration: 220; easing.type: Easing.OutCubic }
            PauseAnimation  { duration: 2800 }
            NumberAnimation { target: toastRect; property: "opacity"; to: 0; duration: 400; easing.type: Easing.InCubic }
        }
    }
}
