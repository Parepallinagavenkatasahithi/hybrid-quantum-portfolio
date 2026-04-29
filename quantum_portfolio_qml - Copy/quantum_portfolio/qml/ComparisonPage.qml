import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    color: "#08090e"
    property real returnGap: portfolioModel.qaoaReturn - portfolioModel.classicalReturn
    property real riskGap: portfolioModel.classicalRisk - portfolioModel.qaoaRisk
    property real sharpeGap: portfolioModel.sharpeQaoa - portfolioModel.sharpeClassical

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
                title: "Comparison"
                subtitle: "Classical Portfolio versus Qml Portfolio"
                badgeText: "VERSUS"
                badgeColor: "#00e5a0"
            }

            Rectangle {
                width: parent.width
                height: 110
                radius: 16
                color: "#0d1320"
                border.color: "#26324d"

                Row {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 16

                    Rectangle {
                        width: (parent.width - 32) / 3
                        height: parent.height
                        radius: 12
                        color: returnGap >= 0 ? "#121b13" : "#1b1111"
                        border.color: returnGap >= 0 ? "#00e5a0" : "#ff7777"

                        Column {
                            anchors.centerIn: parent
                            spacing: 3
                            Text { text: "RETURN EDGE"; font.pixelSize: 9; font.letterSpacing: 1.4; color: "#7f89a6" }
                            Text { text: (returnGap >= 0 ? "QML +" : "CLASSICAL +") + Math.abs(returnGap).toFixed(2) + "%"; font.pixelSize: 24; font.bold: true; color: returnGap >= 0 ? "#00e5a0" : "#ff7777" }
                            Text { text: returnGap >= 0 ? "Higher upside from the QML portfolio" : "Classical is still leading on return"; font.pixelSize: 12; color: "#aab3d0" }
                        }
                    }

                    Rectangle {
                        width: (parent.width - 32) / 3
                        height: parent.height
                        radius: 12
                        color: riskGap >= 0 ? "#101321" : "#201115"
                        border.color: riskGap >= 0 ? "#4db7ff" : "#ff7777"

                        Column {
                            anchors.centerIn: parent
                            spacing: 3
                            Text { text: "RISK EDGE"; font.pixelSize: 9; font.letterSpacing: 1.4; color: "#7f89a6" }
                            Text { text: (riskGap >= 0 ? "QML -" : "CLASSICAL -") + Math.abs(riskGap).toFixed(2) + "%"; font.pixelSize: 24; font.bold: true; color: riskGap >= 0 ? "#4db7ff" : "#ff7777" }
                            Text { text: riskGap >= 0 ? "Lower volatility on the QML side" : "Classical is safer right now"; font.pixelSize: 12; color: "#aab3d0" }
                        }
                    }

                    Rectangle {
                        width: (parent.width - 32) / 3
                        height: parent.height
                        radius: 12
                        color: sharpeGap >= 0 ? "#1a1022" : "#221512"
                        border.color: sharpeGap >= 0 ? "#b060ff" : "#ff9a57"

                        Column {
                            anchors.centerIn: parent
                            spacing: 3
                            Text { text: "SHARPE EDGE"; font.pixelSize: 9; font.letterSpacing: 1.4; color: "#7f89a6" }
                            Text { text: (sharpeGap >= 0 ? "QML +" : "CLASSICAL +") + Math.abs(sharpeGap).toFixed(2); font.pixelSize: 24; font.bold: true; color: sharpeGap >= 0 ? "#b060ff" : "#ff9a57" }
                            Text { text: sharpeGap >= 0 ? "Better risk-adjusted efficiency" : "Classical is more efficient"; font.pixelSize: 12; color: "#aab3d0" }
                        }
                    }
                }
            }

            Row {
                width: parent.width
                spacing: 14

                Rectangle {
                    width: (parent.width - 14) / 2
                    height: 210
                    color: "#0a1a14"
                    border.color: "#00d4ff"
                    border.width: 1
                    radius: 12

                    Column {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 10

                        Text { text: "CLASSICAL PORTFOLIO"; font.pixelSize: 12; font.letterSpacing: 1.5; color: "#00d4ff" }
                        Text { text: returnGap < 0 ? "LEADING ON RETURN" : (riskGap < 0 ? "LEADING ON RISK" : ""); font.pixelSize: 10; font.letterSpacing: 1.4; color: "#6c7694" }
                        ComparisonRow { label: "Return"; value: portfolioModel.classicalReturn.toFixed(2) + "%"; col: "#00e5a0" }
                        ComparisonRow { label: "Risk"; value: portfolioModel.classicalRisk.toFixed(2) + "%"; col: "#ffb347" }
                        ComparisonRow { label: "Sharpe"; value: portfolioModel.sharpeClassical.toFixed(2); col: "#00d4ff" }
                        ComparisonRow { label: "Style"; value: "Deterministic optimizer"; col: "#8892b0" }
                    }
                }

                Rectangle {
                    width: (parent.width - 14) / 2
                    height: 210
                    color: "#110a1e"
                    border.color: "#b060ff"
                    border.width: 1
                    radius: 12

                    Column {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 10

                        Text { text: "QML PORTFOLIO"; font.pixelSize: 12; font.letterSpacing: 1.5; color: "#b060ff" }
                        Text { text: returnGap >= 0 && riskGap >= 0 ? "" : (sharpeGap >= 0 ? "BETTER EFFICIENCY" : "ALTERNATE PROFILE"); font.pixelSize: 10; font.letterSpacing: 1.4; color: "#cab8ff" }
                        ComparisonRow { label: "Return"; value: portfolioModel.qaoaReturn.toFixed(2) + "%"; col: "#b060ff" }
                        ComparisonRow { label: "Risk"; value: portfolioModel.qaoaRisk.toFixed(2) + "%"; col: "#ff77aa" }
                        ComparisonRow { label: "Sharpe"; value: portfolioModel.sharpeQaoa.toFixed(2); col: "#b060ff" }
                        ComparisonRow { label: "Style"; value: "Quantum-inspired selection"; col: "#8892b0" }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 320
                color: "#0f1018"
                border.color: "#2a2d45"
                radius: 12

                Column {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12

                    Text {
                        text: "ALLOCATION COMPARISON"
                        font.pixelSize: 10
                        font.letterSpacing: 1.5
                        color: "#4a5068"
                    }

                    Canvas {
                        id: compCanvas
                        width: parent.width
                        height: 255
                        property var classicalValues: portfolioModel.classicalWeights
                        property var qmlValues: portfolioModel.qaoaWeights
                        property var names: portfolioModel.assetNames
                        onClassicalValuesChanged: requestPaint()
                        onQmlValuesChanged: requestPaint()
                        onNamesChanged: requestPaint()

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)

                            var n = names.length
                            if (n === 0)
                                return

                            var allVals = classicalValues.concat(qmlValues)
                            var maxVal = 1
                            for (var v = 0; v < allVals.length; v++) {
                                var numericValue = Number(allVals[v] || 0)
                                if (numericValue > maxVal)
                                    maxVal = numericValue
                            }
                            var groupW = Math.min(90, (width - 70) / n)
                            var barW = groupW * 0.34
                            var chartH = height - 55
                            var startX = 40

                            for (var i = 0; i < n; i++) {
                                var gx = startX + i * groupW
                                var ch = (Number(classicalValues[i]) / maxVal) * chartH
                                var qh = (Number(qmlValues[i]) / maxVal) * chartH

                                ctx.fillStyle = "#00d4ff"
                                ctx.fillRect(gx, chartH - ch + 10, barW, ch)

                                ctx.fillStyle = "#b060ff"
                                ctx.fillRect(gx + barW + 6, chartH - qh + 10, barW, qh)

                                ctx.fillStyle = "#4a5068"
                                ctx.font = "9px sans-serif"
                                ctx.textAlign = "center"
                                ctx.fillText(names[i], gx + groupW / 2 - 2, height - 10)
                            }
                        }
                    }
                }
            }
        }
    }
}
