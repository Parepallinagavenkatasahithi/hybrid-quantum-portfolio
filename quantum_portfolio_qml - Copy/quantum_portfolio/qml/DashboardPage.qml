import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    color: "#08090e"

    Flickable {
        anchors.fill: parent
        contentHeight: mainCol.implicitHeight + 40
        clip: true

        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        Column {
            id: mainCol
            anchors { left: parent.left; right: parent.right; top: parent.top }
            anchors.margins: 28
            spacing: 22

            // ── Header ─────────────────────────────────────────
            Item {
                width: parent.width
                height: 64

                Column {
                    spacing: 4
                    Text {
                        text: "Portfolio Dashboard"
                        font.pixelSize: 26
                        font.weight: Font.Bold
                        color: "#e8eaf6"
                    }
                    Text {
                        text: portfolioModel.isLoading
                              ? portfolioModel.status
                              : (portfolioModel.assetNames.length > 0
                                 ? portfolioModel.dataSourceLabel + "  |  " + portfolioModel.assetNames.join("  |  ")
                                 : "Select assets in Settings and hit Optimize")
                        font.pixelSize: 12
                        color: "#4a5068"
                    }
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10

                    Rectangle {
                        width: portfolioModel.assetNames.length > 0 ? 168 : 148
                        height: 32
                        radius: 16
                        color: portfolioModel.isDemoMode ? "#21170a" : "#0a1a14"
                        border.color: portfolioModel.isDemoMode ? "#ffb347" : "#00e5a0"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: portfolioModel.assetNames.length > 0
                                  ? (portfolioModel.isDemoMode ? "DEMO DATA MODE" : "LIVE MARKET DATA")
                                  : "READY TO RUN"
                            font.pixelSize: 10
                            font.letterSpacing: 1
                            font.weight: Font.DemiBold
                            color: portfolioModel.isDemoMode ? "#ffb347" : "#00e5a0"
                        }
                    }

                    Rectangle {
                        width: 140
                        height: 32
                        radius: 16
                        color: "#1a0a2e"
                        border.color: "#b060ff"
                        border.width: 1

                        Row {
                            anchors.centerIn: parent
                            spacing: 6
                            Text { text: "Q"; font.pixelSize: 13; color: "#b060ff" }
                            Text {
                                text: "QAOA ENABLED"
                                font.pixelSize: 10
                                font.letterSpacing: 1
                                font.weight: Font.DemiBold
                                color: "#b060ff"
                            }
                        }
                    }
                }
            }

            // ── Metric row ─────────────────────────────────────
            Row {
                width: parent.width
                spacing: 14

                MetricTile {
                    width: (parent.width - 56) / 5
                    label: "CLASSICAL RETURN"
                    value: portfolioModel.classicalReturn > 0
                           ? portfolioModel.classicalReturn.toFixed(3) + "%"
                           : "--"
                    accentColor: "#00e5a0"
                    trend: portfolioModel.classicalReturn > 0 ? "up" : ""
                }
                MetricTile {
                    width: (parent.width - 56) / 5
                    label: "CLASSICAL RISK"
                    value: portfolioModel.classicalRisk > 0
                           ? portfolioModel.classicalRisk.toFixed(4) + "%"
                           : "--"
                    accentColor: "#ffb347"
                }
                MetricTile {
                    width: (parent.width - 56) / 5
                    label: "QAOA RETURN"
                    value: portfolioModel.qaoaReturn > 0
                           ? portfolioModel.qaoaReturn.toFixed(3) + "%"
                           : "--"
                    accentColor: "#b060ff"
                    trend: portfolioModel.qaoaReturn > 0 ? "up" : ""
                }
                MetricTile {
                    width: (parent.width - 56) / 5
                    label: "SHARPE (CLASSICAL)"
                    value: portfolioModel.sharpeClassical !== 0
                           ? portfolioModel.sharpeClassical.toFixed(2)
                           : "--"
                    accentColor: "#00d4ff"
                }
                MetricTile {
                    width: (parent.width - 56) / 5
                    label: "SHARPE (QAOA)"
                    value: portfolioModel.sharpeQaoa !== 0
                           ? portfolioModel.sharpeQaoa.toFixed(2)
                           : "--"
                    accentColor: "#b060ff"
                }
            }

            // ── Two-column charts ──────────────────────────────
            Row {
                width: parent.width
                spacing: 14

                // Classical allocation donut
                Rectangle {
                    width: (parent.width - 14) * 0.48
                    height: 320
                    color: "#0f1018"
                    border.color: "#2a2d45"
                    radius: 12

                    Column {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 14

                        Text {
                            text: "CLASSICAL ALLOCATION"
                            font.pixelSize: 10
                            font.letterSpacing: 1.5
                            color: "#4a5068"
                        }

                        DonutChart {
                            width: parent.width
                            height: 260
                            names: portfolioModel.assetNames
                            values: portfolioModel.classicalWeights
                            accentColor: "#00d4ff"
                        }
                    }
                }

                // QAOA allocation donut
                Rectangle {
                    width: (parent.width - 14) * 0.52
                    height: 320
                    color: "#0f1018"
                    border.color: "#2a2d45"
                    radius: 12

                    Column {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 14

                        Text {
                            text: "QAOA ALLOCATION"
                            font.pixelSize: 10
                            font.letterSpacing: 1.5
                            color: "#4a5068"
                        }

                        DonutChart {
                            width: parent.width
                            height: 260
                            names: portfolioModel.assetNames
                            values: portfolioModel.qaoaWeights
                            accentColor: "#b060ff"
                        }
                    }
                }
            }

            // ── Asset table ────────────────────────────────────
            Rectangle {
                width: parent.width
                height: Math.max(180, 44 + 38 * Math.min(portfolioModel.assetNames.length, 35))
                color: "#0f1018"
                border.color: "#2a2d45"
                radius: 12

                Column {
                    anchors.fill: parent
                    anchors.margins: 0
                    spacing: 0

                    // Header
                    Rectangle {
                        width: parent.width
                        height: 44
                        color: "#161822"
                        radius: 12
                        // Bottom corners not rounded
                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 12
                            color: "#161822"
                        }

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 20
                            anchors.rightMargin: 20

                            Repeater {
                                model: ["ASSET", "CLASSICAL ($)", "QAOA ($)", "BLENDED ($)"]
                                delegate: Text {
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

                    // Rows
                    Repeater {
                        model: portfolioModel.assetNames
                        delegate: Rectangle {
                            width: parent.width
                            height: 38
                            color: index % 2 === 0 ? "transparent" : "#0a0b12"

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 20
                                anchors.rightMargin: 20

                                Text {
                                    width: parent.width / 4
                                    height: parent.height
                                    text: modelData
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: 13
                                    font.weight: Font.DemiBold
                                    color: "#e8eaf6"
                                }
                                Text {
                                    width: parent.width / 4
                                    height: parent.height
                                    text: portfolioModel.classicalWeights[index] !== undefined
                                          ? "$" + portfolioModel.classicalWeights[index].toFixed(2)
                                          : "--"
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: 12
                                    color: "#00e5a0"
                                }
                                Text {
                                    width: parent.width / 4
                                    height: parent.height
                                    text: portfolioModel.qaoaWeights[index] !== undefined
                                          ? "$" + portfolioModel.qaoaWeights[index].toFixed(2)
                                          : "--"
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: 12
                                    color: "#b060ff"
                                }
                                Text {
                                    width: parent.width / 4
                                    height: parent.height
                                    text: portfolioModel.blendedWeights[index] !== undefined
                                          ? "$" + portfolioModel.blendedWeights[index].toFixed(2)
                                          : "--"
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: 12
                                    color: "#00d4ff"
                                }
                            }
                        }
                    }
                }
            }

            Item { height: 10 }
        }
    }
}
