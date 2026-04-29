import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    color: "#08090e"
    property real zoomLevel: 1.0
    property real pinchStartZoom: 1.0

    Flickable {
        anchors.fill: parent
        contentHeight: col.implicitHeight + 40
        clip: true
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        Column {
            id: col
            anchors { left: parent.left; right: parent.right; top: parent.top }
            anchors.margins: 28
            spacing: 22

            PageHeader {
                title: "Correlation Heatmap"
                subtitle: "Pairwise asset return correlations"
                badgeText: "HEATMAP"
                badgeColor: "#ffb347"
            }

            Rectangle {
                width: parent.width
                height: 560
                color: "#0f1018"
                border.color: "#2a2d45"
                radius: 12

                Row {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8
                    z: 2

                    Rectangle {
                        width: 34
                        height: 30
                        radius: 8
                        color: zoomMouseMinus.containsMouse ? "#1f2a3f" : "#171c2a"
                        border.color: "#34415f"
                        Text { anchors.centerIn: parent; text: "-"; color: "#d8def2"; font.pixelSize: 18 }
                        MouseArea {
                            id: zoomMouseMinus
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: zoomLevel = Math.max(0.6, zoomLevel - 0.2)
                        }
                    }

                    Rectangle {
                        width: 62
                        height: 30
                        radius: 8
                        color: "#121724"
                        border.color: "#34415f"
                        Text {
                            anchors.centerIn: parent
                            text: Math.round(zoomLevel * 100) + "%"
                            color: "#d8def2"
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                        }
                    }

                    Rectangle {
                        width: 34
                        height: 30
                        radius: 8
                        color: zoomMousePlus.containsMouse ? "#1f2a3f" : "#171c2a"
                        border.color: "#34415f"
                        Text { anchors.centerIn: parent; text: "+"; color: "#d8def2"; font.pixelSize: 16 }
                        MouseArea {
                            id: zoomMousePlus
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: zoomLevel = Math.min(3.0, zoomLevel + 0.2)
                        }
                    }

                    Rectangle {
                        width: 56
                        height: 30
                        radius: 8
                        color: zoomMouseReset.containsMouse ? "#1f2a3f" : "#171c2a"
                        border.color: "#34415f"
                        Text { anchors.centerIn: parent; text: "Reset"; color: "#d8def2"; font.pixelSize: 11 }
                        MouseArea {
                            id: zoomMouseReset
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: zoomLevel = 1.0
                        }
                    }
                }

                Flickable {
                    anchors.fill: parent
                    anchors.margins: 14
                    anchors.topMargin: 50
                    clip: true
                    contentWidth: heatCanvas.width
                    contentHeight: heatCanvas.height
                    ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AsNeeded }
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                    Canvas {
                        id: heatCanvas
                        property var corrData: portfolioModel.correlationData
                        property var labels: {
                            var arr = []
                            var data = corrData
                            for (var i = 0; i < data.length; ++i) {
                                if (arr.indexOf(data[i].row) === -1)
                                    arr.push(data[i].row)
                            }
                            return arr
                        }
                        property int matrixSize: labels.length
                        width: Math.max(parent.width, 90 + matrixSize * 48 * zoomLevel)
                        height: Math.max(parent.height, 120 + matrixSize * 48 * zoomLevel)
                        onCorrDataChanged: requestPaint()
                        onWidthChanged: requestPaint()
                        onHeightChanged: requestPaint()
                        Component.onCompleted: requestPaint()

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)

                            var data = corrData
                            if (!data || data.length === 0) {
                                ctx.fillStyle = "#2a2d45"
                                ctx.font = "13px sans-serif"
                                ctx.textAlign = "center"
                                ctx.fillText("Run optimization to see correlations", width / 2, height / 2)
                                return
                            }

                            var n = labels.length
                            if (n === 0)
                                return

                            var labelW = 78
                            var labelH = 58
                            var cellSize = Math.max(28, 44 * zoomLevel)
                            var offsetX = labelW
                            var offsetY = labelH

                            // Column labels
                            ctx.font = (10 + zoomLevel) + "px sans-serif"
                            ctx.fillStyle = "#8d97b5"
                            ctx.textAlign = "center"
                            for (var ci = 0; ci < n; ci++) {
                                ctx.save()
                                ctx.translate(offsetX + ci * cellSize + cellSize / 2, offsetY - 10)
                                ctx.rotate(-0.55)
                                ctx.fillText(labels[ci], 0, 0)
                                ctx.restore()
                            }

                            // Row labels
                            ctx.textAlign = "right"
                            for (var ri = 0; ri < n; ri++) {
                                ctx.fillText(labels[ri], offsetX - 10, offsetY + ri * cellSize + cellSize / 2 + 4)
                            }

                            for (var row = 0; row < n; ++row) {
                                for (var col = 0; col < n; ++col) {
                                    ctx.strokeStyle = "#171b29"
                                    ctx.strokeRect(offsetX + col * cellSize, offsetY + row * cellSize, cellSize, cellSize)
                                }
                            }

                            // Cells
                            for (var itemIndex = 0; itemIndex < data.length; itemIndex++) {
                                var item = data[itemIndex]
                                var colIndex = labels.indexOf(item.col)
                                var rowIndex = labels.indexOf(item.row)
                                var v = Number(item.value)
                                var x = offsetX + colIndex * cellSize
                                var y = offsetY + rowIndex * cellSize

                                var t = (v + 1) / 2.0
                                var r2 = Math.round(49 + t * 171)
                                var g2 = Math.round(72 + (1 - Math.abs(v)) * 90)
                                var b2 = Math.round(140 + (1 - t) * 90)
                                if (v > 0) {
                                    r2 = Math.round(120 + v * 120)
                                    g2 = Math.round(92 + (1 - v) * 70)
                                    b2 = Math.round(102 + (1 - v) * 90)
                                } else {
                                    r2 = Math.round(60 + (1 + v) * 85)
                                    g2 = Math.round(95 + (1 + v) * 55)
                                    b2 = Math.round(155 + Math.abs(v) * 90)
                                }

                                ctx.fillStyle = "rgb(" + Math.max(0, Math.min(255, r2)) + "," + Math.max(0, Math.min(255, g2)) + "," + Math.max(0, Math.min(255, b2)) + ")"
                                ctx.fillRect(x + 1, y + 1, cellSize - 2, cellSize - 2)

                                if (cellSize >= 34) {
                                    ctx.fillStyle = Math.abs(v) > 0.45 ? "#ffffff" : "#d8def2"
                                    ctx.font = (9 + zoomLevel * 1.5) + "px sans-serif"
                                    ctx.textAlign = "center"
                                    ctx.fillText(v.toFixed(2), x + cellSize / 2, y + cellSize / 2 + 4)
                                }
                            }

                            // Legend
                            var lgX = offsetX
                            var lgY = offsetY + n * cellSize + 20
                            var lgW = Math.max(220, n * cellSize * 0.7)
                            var lgH = 14
                            for (var li = 0; li < lgW; li++) {
                                var lv = (li / lgW) * 2 - 1
                                var rr, gg, bb
                                if (lv > 0) {
                                    rr = Math.round(120 + lv * 120)
                                    gg = Math.round(92 + (1 - lv) * 70)
                                    bb = Math.round(102 + (1 - lv) * 90)
                                } else {
                                    rr = Math.round(60 + (1 + lv) * 85)
                                    gg = Math.round(95 + (1 + lv) * 55)
                                    bb = Math.round(155 + Math.abs(lv) * 90)
                                }
                                ctx.fillStyle = "rgb(" + Math.max(0, Math.min(255, rr)) + "," + Math.max(0, Math.min(255, gg)) + "," + Math.max(0, Math.min(255, bb)) + ")"
                                ctx.fillRect(lgX + li, lgY, 1, lgH)
                            }

                            ctx.fillStyle = "#7f89a6"
                            ctx.font = "10px sans-serif"
                            ctx.textAlign = "left"
                            ctx.fillText("-1.00", lgX, lgY + lgH + 14)
                            ctx.textAlign = "center"
                            ctx.fillText("0.00", lgX + lgW / 2, lgY + lgH + 14)
                            ctx.textAlign = "right"
                            ctx.fillText("+1.00", lgX + lgW, lgY + lgH + 14)
                            ctx.textAlign = "left"
                            ctx.fillText("Correlation", lgX, lgY - 6)
                        }
                    }

                    PinchArea {
                        anchors.fill: parent
                        onPinchStarted: {
                            pinchStartZoom = zoomLevel
                        }
                        onPinchUpdated: {
                            zoomLevel = Math.max(0.6, Math.min(3.0, pinchStartZoom * pinch.scale))
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        onWheel: function(wheel) {
                            if (wheel.angleDelta.y > 0)
                                zoomLevel = Math.min(3.0, zoomLevel + 0.1)
                            else if (wheel.angleDelta.y < 0)
                                zoomLevel = Math.max(0.6, zoomLevel - 0.1)
                            wheel.accepted = true
                        }
                    }
                }
            }

            Item { height: 10 }
        }
    }
}
