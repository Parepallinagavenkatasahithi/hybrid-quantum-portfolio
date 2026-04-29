import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    color: "#08090e"
    property string exportedPath: ""

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
                title: "Download"
                subtitle: "Export allocation and metrics reports from the QML app"
                badgeText: "EXPORT"
                badgeColor: "#ffb347"
            }

            Row {
                width: parent.width
                spacing: 14

                MetricTile {
                    width: (parent.width - 28) / 3
                    label: "CLASSICAL RETURN"
                    value: portfolioModel.classicalReturn.toFixed(2) + "%"
                    accentColor: "#00d4ff"
                }
                MetricTile {
                    width: (parent.width - 28) / 3
                    label: "QML RETURN"
                    value: portfolioModel.qaoaReturn.toFixed(2) + "%"
                    accentColor: "#b060ff"
                }
                MetricTile {
                    width: (parent.width - 28) / 3
                    label: "ASSETS INCLUDED"
                    value: portfolioModel.assetNames.length.toString()
                    accentColor: "#00e5a0"
                }
            }

            Rectangle {
                width: parent.width
                height: 220
                color: "#0f1018"
                border.color: "#2a2d45"
                radius: 12

                Column {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 16

                    Text {
                        text: "EXPORT REPORTS"
                        font.pixelSize: 10
                        font.letterSpacing: 1.5
                        color: "#4a5068"
                    }

                    Row {
                        spacing: 10
                        Button {
                            text: "Download CSV"
                            onClicked: exportedPath = portfolioModel.exportReportAs("csv")
                        }
                        Button {
                            text: "Download JSON"
                            onClicked: exportedPath = portfolioModel.exportReportAs("json")
                        }
                    }

                    Row {
                        spacing: 10
                        Button {
                            text: "Download XLSX"
                            onClicked: exportedPath = portfolioModel.exportReportAs("xlsx")
                        }
                        Button {
                            text: "Download PDF"
                            onClicked: exportedPath = portfolioModel.exportReportAs("pdf")
                        }
                    }

                    Text {
                        text: exportedPath.length > 0 ? "Saved to: " + exportedPath : "No export generated yet."
                        wrapMode: Text.WordWrap
                        font.pixelSize: 12
                        color: exportedPath.length > 0 ? "#00e5a0" : "#4a5068"
                    }
                }
            }
        }
    }
}
