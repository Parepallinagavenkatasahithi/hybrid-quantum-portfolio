import QtQuick

Item {
    id: root
    property var names: []
    property var values: []
    property color accentColor: "#00d4ff"

    property var sliceColors: [
        "#00d4ff", "#b060ff", "#00e5a0", "#ffb347",
        "#ff5555", "#5577ff", "#ff77aa", "#44ddbb",
        "#ffdd44", "#aa66ff"
    ]

    onValuesChanged: canvas.requestPaint()
    onNamesChanged: canvas.requestPaint()

    Row {
        anchors.fill: parent
        spacing: 0

        Canvas {
            id: canvas
            width: Math.max(0, Math.min(parent.height, parent.width * 0.55))
            height: Math.max(0, parent.height)

            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
            Component.onCompleted: requestPaint()

            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)

                if (width <= 0 || height <= 0)
                    return

                var total = 0
                for (var i = 0; i < root.values.length; i++)
                    total += Number(root.values[i] || 0)

                var cx = width / 2
                var cy = height / 2
                var radius = Math.min(width, height) * 0.38
                var lineW = 28

                if (!isFinite(radius) || radius <= 0)
                    return

                if (total <= 0) {
                    ctx.beginPath()
                    ctx.arc(cx, cy, radius, 0, Math.PI * 2, false)
                    ctx.strokeStyle = "#1e2030"
                    ctx.lineWidth = lineW
                    ctx.stroke()
                    ctx.fillStyle = "#2a2d45"
                    ctx.font = "12px sans-serif"
                    ctx.textAlign = "center"
                    ctx.fillText("No data", cx, cy + 4)
                    return
                }

                var startAngle = -Math.PI / 2
                for (var j = 0; j < root.values.length; j++) {
                    var currentValue = Number(root.values[j] || 0)
                    if (currentValue <= 0)
                        continue

                    var slice = (currentValue / total) * Math.PI * 2
                    if (!isFinite(slice) || slice <= 0)
                        continue

                    ctx.beginPath()
                    ctx.arc(cx, cy, radius, startAngle, startAngle + slice, false)
                    ctx.strokeStyle = root.sliceColors[j % root.sliceColors.length]
                    ctx.lineWidth = lineW
                    ctx.stroke()
                    startAngle += slice + 0.02
                }

                ctx.fillStyle = "#e8eaf6"
                ctx.font = "bold 16px sans-serif"
                ctx.textAlign = "center"
                ctx.textBaseline = "middle"
                ctx.fillText("$" + (total / 1000).toFixed(0) + "K", cx, cy - 8)
                ctx.fillStyle = "#4a5068"
                ctx.font = "10px sans-serif"
                ctx.fillText("total", cx, cy + 10)
            }
        }

        Column {
            width: Math.max(0, parent.width - canvas.width)
            height: parent.height
            spacing: 0

            Flickable {
                width: parent.width
                height: parent.height
                contentHeight: legendCol.implicitHeight
                clip: true

                Column {
                    id: legendCol
                    width: parent.width
                    spacing: 0

                    Repeater {
                        model: root.names

                        delegate: Row {
                            width: parent.width
                            height: 26
                            spacing: 8

                            Item {
                                width: 8
                                height: parent.height

                                Rectangle {
                                    width: 8
                                    height: 8
                                    radius: 4
                                    color: root.sliceColors[index % root.sliceColors.length]
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Text {
                                text: modelData
                                font.pixelSize: 11
                                color: "#8892b0"
                                width: parent.width * 0.45
                                anchors.verticalCenter: parent.verticalCenter
                                elide: Text.ElideRight
                            }

                            Text {
                                text: root.values[index] !== undefined
                                      ? "$" + Number(root.values[index]).toFixed(0)
                                      : ""
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                color: root.sliceColors[index % root.sliceColors.length]
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }
        }
    }
}
