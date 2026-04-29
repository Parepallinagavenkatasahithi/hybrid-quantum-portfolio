import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    color: "#08090e"
    property real classicalCrash: portfolioModel.classicalReturn * 0.7
    property real qmlCrash: portfolioModel.qaoaReturn * 0.75
    property real classicalBull: portfolioModel.classicalReturn * 1.2
    property real qmlBull: portfolioModel.qaoaReturn * 1.25

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
                title: "Stress Test"
                subtitle: "Crash and bull-run scenario comparison for the current portfolio"
                badgeText: "RESILIENCE"
                badgeColor: "#00e5a0"
            }

            Row {
                width: parent.width
                spacing: 14

                MetricTile {
                    width: (parent.width - 28) / 3
                    label: "MARKET CRASH EDGE"
                    value: (qmlCrash - classicalCrash >= 0 ? "+" : "") + (qmlCrash - classicalCrash).toFixed(2) + "%"
                    accentColor: "#00d4ff"
                }
                MetricTile {
                    width: (parent.width - 28) / 3
                    label: "BULL RUN EDGE"
                    value: (qmlBull - classicalBull >= 0 ? "+" : "") + (qmlBull - classicalBull).toFixed(2) + "%"
                    accentColor: "#ffb347"
                }
                MetricTile {
                    width: (parent.width - 28) / 3
                    label: "QML RISK"
                    value: portfolioModel.qaoaRisk.toFixed(2) + "%"
                    accentColor: "#b060ff"
                }
            }

            Rectangle {
                width: parent.width
                height: 430
                color: "#0f1018"
                border.color: "#2a2d45"
                radius: 12

                Column {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12

                    Text {
                        text: "STRESS TEST RESULTS"
                        font.pixelSize: 10
                        font.letterSpacing: 1.5
                        color: "#4a5068"
                    }

                    Canvas {
                        id: stressCanvas
                        width: parent.width
                        height: 360
                        onWidthChanged: requestPaint()
                        Component.onCompleted: requestPaint()
                        Connections {
                            target: portfolioModel
                            function onMetricsChanged() { stressCanvas.requestPaint() }
                        }

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)

                            var values = [
                                classicalCrash,
                                qmlCrash,
                                classicalBull,
                                qmlBull
                            ]
                            var maxVal = 1
                            for (var v = 0; v < values.length; ++v)
                                maxVal = Math.max(maxVal, Math.abs(values[v]))

                            var chartTop = 28
                            var chartBottom = height - 58
                            var chartHeight = chartBottom - chartTop
                            var baseY = chartBottom
                            var groupWidth = (width - 120) / 2
                            var barWidth = Math.min(68, groupWidth * 0.22)
                            var startX = 90
                            var scenarios = [
                                { name: "Market Crash", classical: classicalCrash, qml: qmlCrash },
                                { name: "Bull Run", classical: classicalBull, qml: qmlBull }
                            ]

                            ctx.strokeStyle = "#1e2030"
                            ctx.lineWidth = 1
                            for (var g = 0; g <= 4; ++g) {
                                var gy = chartTop + g * chartHeight / 4
                                ctx.beginPath()
                                ctx.moveTo(54, gy)
                                ctx.lineTo(width - 28, gy)
                                ctx.stroke()

                                var axisValue = maxVal * (1 - g / 4)
                                ctx.fillStyle = "#66708d"
                                ctx.font = "10px sans-serif"
                                ctx.textAlign = "right"
                                ctx.fillText(axisValue.toFixed(0) + "%", 48, gy + 4)
                            }

                            for (var i = 0; i < scenarios.length; ++i) {
                                var groupX = startX + i * groupWidth
                                var classicalHeight = (Math.abs(scenarios[i].classical) / maxVal) * chartHeight
                                var qmlHeight = (Math.abs(scenarios[i].qml) / maxVal) * chartHeight

                                ctx.fillStyle = "#00d4ff"
                                ctx.fillRect(groupX, baseY - classicalHeight, barWidth, classicalHeight)
                                ctx.fillStyle = "#b060ff"
                                ctx.fillRect(groupX + barWidth + 14, baseY - qmlHeight, barWidth, qmlHeight)

                                ctx.fillStyle = "#9aa4c4"
                                ctx.font = "11px sans-serif"
                                ctx.textAlign = "center"
                                ctx.fillText("Classical", groupX + barWidth / 2, baseY + 16)
                                ctx.fillText("QML", groupX + barWidth + 14 + barWidth / 2, baseY + 16)

                                ctx.fillStyle = "#d8def2"
                                ctx.font = "12px sans-serif"
                                ctx.fillText(scenarios[i].name, groupX + barWidth + 7, height - 12)

                                ctx.fillStyle = "#00d4ff"
                                ctx.fillText(scenarios[i].classical.toFixed(2) + "%", groupX + barWidth / 2, baseY - classicalHeight - 8)
                                ctx.fillStyle = "#b060ff"
                                ctx.fillText(scenarios[i].qml.toFixed(2) + "%", groupX + barWidth + 14 + barWidth / 2, baseY - qmlHeight - 8)
                            }
                        }
                    }
                }
            }
        }
    }
}
