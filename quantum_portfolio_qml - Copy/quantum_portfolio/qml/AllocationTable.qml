import QtQuick
import QtQuick.Layouts

Rectangle {
    property var names: []
    property var weights: []
    property color accentColor: "#00d4ff"
    property real budget: 100000

    height: Math.max(120, 48 + 38 * Math.min(names.length, 35))
    color: "#0f1018"
    border.color: "#2a2d45"
    radius: 12

    Column {
        anchors.fill: parent

        // Header
        Rectangle {
            width: parent.width
            height: 48
            color: "#161822"
            radius: 12
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width; height: 12
                color: "#161822"
            }

            Row {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20

                Repeater {
                    model: ["ASSET", "ALLOCATION ($)", "WEIGHT (%)", "SHARES (EST)"]
                    Text {
                        width: parent.width / 4
                        height: parent.height
                        text: modelData
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 10
                        font.letterSpacing: 1.2
                        color: "#4a5068"
                    }
                }
            }
        }

        Flickable {
            width: parent.width
            height: parent.height - 48
            contentHeight: rowsCol.implicitHeight
            clip: true

            Column {
                id: rowsCol
                width: parent.width

                Repeater {
                    model: names
                    Rectangle {
                        width: parent.width
                        height: 38
                        color: index % 2 === 0 ? "transparent" : "#0a0b12"

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 20
                            anchors.rightMargin: 20

                            Text {
                                width: parent.width / 4; height: parent.height
                                text: modelData
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 13; font.weight: Font.DemiBold
                                color: "#e8eaf6"
                            }
                            Text {
                                width: parent.width / 4; height: parent.height
                                text: weights[index] !== undefined ? "$" + Number(weights[index]).toFixed(2) : "--"
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 12; color: accentColor
                            }
                            Text {
                                width: parent.width / 4; height: parent.height
                                text: (weights[index] !== undefined && budget > 0)
                                      ? (Number(weights[index]) / budget * 100).toFixed(2) + "%"
                                      : "--"
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 12; color: "#8892b0"
                            }
                            Text {
                                width: parent.width / 4; height: parent.height
                                text: weights[index] !== undefined && Number(weights[index]) > 0 ? "~" + Math.floor(Number(weights[index]) / 100).toString() : "--"
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 12; color: "#4a5068"
                            }
                        }
                    }
                }
            }
        }
    }
}
