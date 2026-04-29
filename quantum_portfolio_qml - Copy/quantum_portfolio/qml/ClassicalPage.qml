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
                title: "Classical Portfolio"
                subtitle: "Mean-variance allocation with visible weights, pie chart, and table"
                badgeText: "CLASSICAL"
                badgeColor: "#00d4ff"
            }

            Row {
                width: parent.width
                spacing: 14

                MetricTile {
                    width: (parent.width - 42) / 4
                    label: "EXPECTED RETURN"
                    value: portfolioModel.classicalReturn.toFixed(2) + "%"
                    accentColor: "#00e5a0"
                }
                MetricTile {
                    width: (parent.width - 42) / 4
                    label: "PORTFOLIO RISK"
                    value: portfolioModel.classicalRisk.toFixed(2) + "%"
                    accentColor: "#ffb347"
                }
                MetricTile {
                    width: (parent.width - 42) / 4
                    label: "SHARPE RATIO"
                    value: portfolioModel.sharpeClassical.toFixed(2)
                    accentColor: "#00d4ff"
                }
                MetricTile {
                    width: (parent.width - 42) / 4
                    label: "TOP HOLDING"
                    value: portfolioModel.assetNames.length > 0 ? portfolioModel.assetNames[0] : "--"
                    accentColor: "#b060ff"
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
                            text: "CLASSICAL ALLOCATION"
                            font.pixelSize: 10
                            font.letterSpacing: 1.5
                            color: "#4a5068"
                        }

                        DonutChart {
                            width: parent.width
                            height: 270
                            names: portfolioModel.assetNames
                            values: portfolioModel.classicalWeights
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
                            values: portfolioModel.classicalWeights
                            barColor: "#00d4ff"
                            title: "Classical Weights"
                        }
                    }
                }
            }

            AllocationTable {
                width: parent.width
                names: portfolioModel.assetNames
                weights: portfolioModel.classicalWeights
                accentColor: "#00d4ff"
                budget: portfolioModel.budget
            }
        }
    }
}
