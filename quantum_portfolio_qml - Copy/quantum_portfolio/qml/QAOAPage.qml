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
                title: "Qml Portfolio"
                subtitle: "Quantum-inspired allocation page built fully in QML"
                badgeText: "QML"
                badgeColor: "#b060ff"
            }

            Row {
                width: parent.width
                spacing: 14

                MetricTile {
                    width: (parent.width - 42) / 4
                    label: "QML RETURN"
                    value: portfolioModel.qaoaReturn.toFixed(2) + "%"
                    accentColor: "#b060ff"
                }
                MetricTile {
                    width: (parent.width - 42) / 4
                    label: "QML RISK"
                    value: portfolioModel.qaoaRisk.toFixed(2) + "%"
                    accentColor: "#ff77aa"
                }
                MetricTile {
                    width: (parent.width - 42) / 4
                    label: "QML SHARPE"
                    value: portfolioModel.sharpeQaoa.toFixed(2)
                    accentColor: "#00d4ff"
                }
                MetricTile {
                    width: (parent.width - 42) / 4
                    label: "CIRCUIT DEPTH"
                    value: portfolioModel.reps.toString()
                    accentColor: "#5577ff"
                }
            }

            Row {
                width: parent.width
                spacing: 14

                Rectangle {
                    width: (parent.width - 14) * 0.48
                    height: 340
                    color: "#0f1018"
                    border.color: "#2a2d45"
                    radius: 12

                    Column {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 14

                        Text {
                            text: "QML ALLOCATION"
                            font.pixelSize: 10
                            font.letterSpacing: 1.5
                            color: "#4a5068"
                        }

                        DonutChart {
                            width: parent.width
                            height: 270
                            names: portfolioModel.assetNames
                            values: portfolioModel.qaoaWeights
                        }
                    }
                }

                Rectangle {
                    width: (parent.width - 14) * 0.52
                    height: 340
                    color: "#0f1018"
                    border.color: "#2a2d45"
                    radius: 12

                    Column {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 12

                        Text {
                            text: "WEIGHT DISTRIBUTION"
                            font.pixelSize: 10
                            font.letterSpacing: 1.5
                            color: "#4a5068"
                        }

                        BarChart {
                            width: parent.width
                            height: 270
                            names: portfolioModel.assetNames
                            values: portfolioModel.qaoaWeights
                            barColor: "#b060ff"
                            title: "QML Weights"
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 280
                color: "#0f1018"
                border.color: "#2a2d45"
                radius: 12
                visible: portfolioModel.stabilityData.length > 0

                Column {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12

                    Text {
                        text: "QML STABILITY SIGNAL"
                        font.pixelSize: 10
                        font.letterSpacing: 1.5
                        color: "#4a5068"
                    }

                    Canvas {
                        id: stabilityCanvas
                        width: parent.width
                        height: 220
                        property var chartData: portfolioModel.stabilityData
                        onChartDataChanged: requestPaint()

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            var d = chartData
                            if (!d || d.length === 0)
                                return

                            var n = d.length
                            var barW = Math.min(46, (width - 40) / n - 8)
                            var maxH = height - 38
                            var startX = (width - n * (barW + 8)) / 2

                            for (var i = 0; i < n; i++) {
                                var prob = Number(d[i].probability)
                                var bh = prob * maxH
                                var x = startX + i * (barW + 8)
                                var y = height - 24 - bh

                                ctx.fillStyle = "#b060ff"
                                ctx.fillRect(x, y, barW, bh)
                                ctx.fillStyle = "#4a5068"
                                ctx.font = "9px sans-serif"
                                ctx.textAlign = "center"
                                ctx.fillText(d[i].asset, x + barW / 2, height - 8)
                            }
                        }
                    }
                }
            }

            AllocationTable {
                width: parent.width
                names: portfolioModel.assetNames
                weights: portfolioModel.qaoaWeights
                accentColor: "#b060ff"
                budget: portfolioModel.budget
            }
        }
    }
}
