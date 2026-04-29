import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    color: "#08090e"

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
                title: "Monte Carlo Simulation"
                subtitle: "200 simulated portfolio paths · 126 trading days"
                badgeText: "SIMULATION"
                badgeColor: "#00e5a0"
            }

            // Main chart
            Rectangle {
                width: parent.width
                height: 380
                color: "#0f1018"
                border.color: "#2a2d45"
                radius: 12

                Column {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12

                    Text {
                        text: "PORTFOLIO VALUE PATHS"
                        font.pixelSize: 10
                        font.letterSpacing: 1.5
                        color: "#4a5068"
                    }

                    Canvas {
                        id: mcCanvas
                        width: parent.width
                        height: 320

                        property var paths: portfolioModel.monteCarloData

                        onPathsChanged: requestPaint()

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)

                            var allPaths = paths
                            if (!allPaths || allPaths.length === 0) {
                                ctx.fillStyle = "#2a2d45"
                                ctx.font = "13px sans-serif"
                                ctx.textAlign = "center"
                                ctx.fillText("Run optimization to see Monte Carlo paths", width / 2, height / 2)
                                return
                            }

                            var steps = allPaths[0].length
                            var allVals = [].concat.apply([], allPaths)
                            var minV = Math.min.apply(null, allVals)
                            var maxV = Math.max.apply(null, allVals)
                            var pad = 10

                            function scaleX(i) { return pad + (i / (steps - 1)) * (width - pad * 2) }
                            function scaleY(v) { return height - pad - ((v - minV) / (maxV - minV + 1)) * (height - pad * 2) }

                            // Grid lines
                            ctx.strokeStyle = "#1e2030"
                            ctx.lineWidth = 1
                            for (var g = 0; g <= 4; g++) {
                                var gy = pad + g * (height - pad * 2) / 4
                                ctx.beginPath()
                                ctx.moveTo(pad, gy)
                                ctx.lineTo(width - pad, gy)
                                ctx.stroke()
                                var val = maxV - g * (maxV - minV) / 4
                                ctx.fillStyle = "#4a5068"
                                ctx.font = "9px sans-serif"
                                ctx.textAlign = "left"
                                ctx.fillText("$" + (val / 1000).toFixed(0) + "K", 0, gy + 3)
                            }

                            // Paths
                            for (var p = 0; p < allPaths.length; p++) {
                                var path = allPaths[p]
                                var alpha = 0.55
                                var hue = 180 + p * 15

                                ctx.beginPath()
                                ctx.moveTo(scaleX(0), scaleY(path[0]))
                                for (var s = 1; s < steps; s++) {
                                    ctx.lineTo(scaleX(s), scaleY(path[s]))
                                }
                                ctx.strokeStyle = "hsl(" + hue + ", 80%, 65%)"
                                ctx.globalAlpha = alpha
                                ctx.lineWidth = 1.2
                                ctx.stroke()
                            }
                            ctx.globalAlpha = 1.0

                            // Highlight last path
                            if (allPaths.length > 0) {
                                var last = allPaths[allPaths.length - 1]
                                ctx.beginPath()
                                ctx.moveTo(scaleX(0), scaleY(last[0]))
                                for (var ss = 1; ss < steps; ss++) {
                                    ctx.lineTo(scaleX(ss), scaleY(last[ss]))
                                }
                                ctx.strokeStyle = "#00d4ff"
                                ctx.lineWidth = 2.5
                                ctx.stroke()
                            }
                        }
                    }
                }
            }

            // Info row
            Row {
                width: parent.width
                spacing: 14

                MetricTile {
                    width: (parent.width - 28) / 3
                    label: "SIMULATION PATHS"
                    value: portfolioModel.monteCarloData.length > 0 ? "10" : "--"
                    accentColor: "#00d4ff"
                }
                MetricTile {
                    width: (parent.width - 28) / 3
                    label: "TRADING DAYS"
                    value: portfolioModel.monteCarloData.length > 0
                           ? (portfolioModel.monteCarloData[0] ? portfolioModel.monteCarloData[0].length.toString() : "--")
                           : "--"
                    accentColor: "#00e5a0"
                }
                MetricTile {
                    width: (parent.width - 28) / 3
                    label: "BASE PORTFOLIO"
                    value: portfolioModel.budget > 0 ? "$" + (portfolioModel.budget / 1000).toFixed(0) + "K" : "--"
                    accentColor: "#ffb347"
                }
            }

            Item { height: 10 }
        }
    }
}
