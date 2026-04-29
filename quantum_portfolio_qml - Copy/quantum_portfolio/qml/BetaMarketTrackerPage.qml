import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    color: "#08090e"

    Component.onCompleted: portfolioModel.refreshMarketTracker()

    Flickable {
        anchors.fill: parent
        contentHeight: contentColumn.implicitHeight + 40
        clip: true
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        Column {
            id: contentColumn
            width: parent.width - 56
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 28
            spacing: 22

            PageHeader {
                width: parent.width
                title: "Beta-Market Tracker"
                subtitle: "Live intraday 1 minute market view for selected assets"
                badgeText: "BETA"
                badgeColor: "#4db7ff"
            }

            Text {
                width: parent.width
                visible: portfolioModel.selectedTickers.length > 0
                text: "Tracking: " + portfolioModel.selectedTickers.join(", ")
                color: "#8892b0"
                font.pixelSize: 12
            }

            Rectangle {
                width: parent.width
                visible: portfolioModel.selectedTickers.length === 0
                radius: 14
                color: "#101521"
                border.color: "#2a2d45"
                height: 80

                Text {
                    anchors.centerIn: parent
                    text: "Please select assets to view live charts."
                    color: "#aab3d0"
                    font.pixelSize: 14
                }
            }

            Repeater {
                model: portfolioModel.marketTrackerData

                delegate: Rectangle {
                    width: contentColumn.width
                    radius: 16
                    color: "#0f1018"
                    border.color: "#2a2d45"
                    height: chartColumn.implicitHeight + 28

                    Column {
                        id: chartColumn
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 12

                        Row {
                            width: parent.width
                            spacing: 18

                            Column {
                                spacing: 4
                                Text {
                                    text: "📈 " + (modelData.asset || "--")
                                    color: "#e8eaf6"
                                    font.pixelSize: 16
                                    font.weight: Font.DemiBold
                                }
                                Text {
                                    text: modelData.status || ""
                                    color: "#8892b0"
                                    font.pixelSize: 12
                                }
                            }

                            Item { width: 1; height: 1 }
                        }

                        Row {
                            spacing: 18
                            visible: modelData.points && modelData.points.length > 0

                            Text { text: "Close: " + Number(modelData.latestClose || 0).toFixed(2); color: "#00e5a0"; font.pixelSize: 12 }
                            Text { text: "High: " + Number(modelData.latestHigh || 0).toFixed(2); color: "#4db7ff"; font.pixelSize: 12 }
                            Text { text: "Low: " + Number(modelData.latestLow || 0).toFixed(2); color: "#ffb347"; font.pixelSize: 12 }
                        }

                        BetaCandlestickChart {
                            width: parent.width
                            height: 240
                            visible: modelData.points && modelData.points.length > 0
                            assetName: modelData.asset || ""
                            candles: modelData.points || []
                        }

                        Rectangle {
                            width: parent.width
                            height: 74
                            radius: 12
                            visible: !modelData.points || modelData.points.length === 0
                            color: "#121624"
                            border.color: "#2a2d45"

                            Text {
                                anchors.centerIn: parent
                                text: modelData.status || "No intraday data available."
                                color: "#aab3d0"
                                font.pixelSize: 13
                            }
                        }
                    }
                }
            }
        }
    }

    Timer {
        interval: portfolioModel.marketTrackerRefreshRate * 1000
        repeat: true
        running: true
        triggeredOnStart: false
        onTriggered: {
            if (!portfolioModel.isMarketTrackerLoading && portfolioModel.selectedTickers.length > 0)
                portfolioModel.refreshMarketTracker()
        }
    }
}
