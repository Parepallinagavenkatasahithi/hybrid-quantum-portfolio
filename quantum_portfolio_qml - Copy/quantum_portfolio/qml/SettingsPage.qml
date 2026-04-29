import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root
    color: "#08090e"

    function commitInputs() {
        if (startDateInput.text.trim().length === 0)
            startDateInput.text = portfolioModel.startDate
        else if (startDateInput.text.trim() !== portfolioModel.startDate)
            portfolioModel.setStartDate(startDateInput.text.trim())

        if (endDateInput.text.trim().length === 0)
            endDateInput.text = portfolioModel.endDate
        else if (endDateInput.text.trim() !== portfolioModel.endDate)
            portfolioModel.setEndDate(endDateInput.text.trim())
    }

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
                title: "Settings"
                subtitle: "Configure assets, dates and optimizer parameters"
                badgeText: "CONFIG"
                badgeColor: "#ffb347"
            }

            // Asset selector
            Rectangle {
                width: parent.width
                height: assetCol.implicitHeight + 32
                color: "#0f1018"
                border.color: "#2a2d45"
                radius: 12

                Column {
                    id: assetCol
                    anchors { left: parent.left; right: parent.right; top: parent.top }
                    anchors.margins: 20
                    spacing: 14

                    Text {
                        text: "ASSET SELECTION"
                        font.pixelSize: 10
                        font.letterSpacing: 1.5
                        color: "#4a5068"
                    }

                    Text {
                        text: "Selected: " + portfolioModel.selectedTickers.join(", ")
                        font.pixelSize: 12
                        color: "#00d4ff"
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }

                    Flow {
                        width: parent.width
                        spacing: 8

                        Repeater {
                            model: portfolioModel.availableTickers
                            delegate: Rectangle {
                                property bool selected: portfolioModel.selectedTickers.indexOf(modelData) !== -1
                                width: tickerText.width + 20
                                height: 28
                                radius: 14
                                color: selected ? "#001a22" : "#161822"
                                border.color: selected ? "#00d4ff" : "#2a2d45"
                                border.width: selected ? 1.5 : 1

                                Text {
                                    id: tickerText
                                    anchors.centerIn: parent
                                    text: modelData
                                    font.pixelSize: 11
                                    font.weight: selected ? Font.DemiBold : Font.Normal
                                    color: selected ? "#00d4ff" : "#4a5068"
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (selected)
                                            portfolioModel.removeTicker(modelData)
                                        else
                                            portfolioModel.addTicker(modelData)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Date & budget settings
            Rectangle {
                width: parent.width
                height: settingsCol.implicitHeight + 32
                color: "#0f1018"
                border.color: "#2a2d45"
                radius: 12

                Column {
                    id: settingsCol
                    anchors { left: parent.left; right: parent.right; top: parent.top }
                    anchors.margins: 20
                    spacing: 18

                    Text {
                        text: "PORTFOLIO PARAMETERS"
                        font.pixelSize: 10
                        font.letterSpacing: 1.5
                        color: "#4a5068"
                    }

                    // Budget
                    SettingRow {
                        label: "Budget ($)"
                        width: parent.width

                        SettingSlider {
                            from: 10000; to: 1000000; stepSize: 5000
                            value: portfolioModel.budget
                            onSliderValueChanged: portfolioModel.setBudget(value)
                            displayValue: "$" + (value / 1000).toFixed(0) + "K"
                        }
                    }

                    // QAOA reps
                    SettingRow {
                        label: "QAOA Circuit Depth (p)"
                        width: parent.width

                        SettingSlider {
                            from: 1; to: 5; stepSize: 1
                            value: portfolioModel.reps
                            onSliderValueChanged: portfolioModel.setReps(value)
                            displayValue: value.toFixed(0)
                        }
                    }

                    // Risk aversion
                    SettingRow {
                        label: "Risk Aversion (λ)"
                        width: parent.width

                        SettingSlider {
                            from: 0.1; to: 0.9; stepSize: 0.05
                            value: portfolioModel.riskAversion
                            onSliderValueChanged: portfolioModel.setRiskAversion(value)
                            displayValue: value.toFixed(2)
                        }
                    }

                    // Start date
                    SettingRow {
                        label: "Start Date"
                        width: parent.width

                        Rectangle {
                            width: 200; height: 36
                            color: "#161822"
                            border.color: "#2a2d45"
                            radius: 8

                            TextInput {
                                id: startDateInput
                                anchors.fill: parent
                                anchors.margins: 10
                                text: portfolioModel.startDate
                                color: "#e8eaf6"
                                font.pixelSize: 13
                                verticalAlignment: Text.AlignVCenter
                                onEditingFinished: root.commitInputs()
                                onActiveFocusChanged: if (!activeFocus) root.commitInputs()
                            }
                        }
                    }

                    // End date
                    SettingRow {
                        label: "End Date"
                        width: parent.width

                        Rectangle {
                            width: 200; height: 36
                            color: "#161822"
                            border.color: "#2a2d45"
                            radius: 8

                            TextInput {
                                id: endDateInput
                                anchors.fill: parent
                                anchors.margins: 10
                                text: portfolioModel.endDate
                                color: "#e8eaf6"
                                font.pixelSize: 13
                                verticalAlignment: Text.AlignVCenter
                                onEditingFinished: root.commitInputs()
                                onActiveFocusChanged: if (!activeFocus) root.commitInputs()
                            }
                        }
                    }
                }
            }

            // Info card
            Rectangle {
                width: parent.width
                height: infoCol.implicitHeight + 32
                color: "#0a1018"
                border.color: "#2a2d45"
                radius: 12

                Column {
                    id: infoCol
                    anchors { left: parent.left; right: parent.right; top: parent.top }
                    anchors.margins: 20
                    spacing: 8

                    Text {
                        text: "DEPENDENCIES"
                        font.pixelSize: 10
                        font.letterSpacing: 1.5
                        color: "#4a5068"
                    }

                    Repeater {
                        model: [
                            "PySide6 · Qt 6.x — UI framework",
                            "yfinance — Market data fetch",
                            "cvxpy — Classical mean-variance optimizer",
                            "qiskit + qiskit-optimization — QAOA engine",
                            "numpy / pandas — Data layer"
                        ]
                        delegate: Row {
                            spacing: 8
                            Rectangle { width: 4; height: 4; radius: 2; color: "#2a2d45"; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: modelData; font.pixelSize: 11; color: "#8892b0" }
                        }
                    }
                }
            }

            Item { height: 10 }
        }
    }
}
