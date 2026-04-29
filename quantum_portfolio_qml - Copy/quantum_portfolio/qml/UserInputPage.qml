import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#08090e"

    function commitAssetInput() {
        var normalized = assetInput.text.trim()
        if (normalized.length === 0) {
            assetInput.text = portfolioModel.selectedTickers.join(", ")
            return
        }
        if (normalized !== portfolioModel.selectedTickers.join(", "))
            portfolioModel.setSelectedTickersFromText(normalized)
    }

    function commitDateInputs() {
        var startValue = startDateInput.text.trim()
        var endValue = endDateInput.text.trim()

        if (startValue.length === 0)
            startDateInput.text = portfolioModel.startDate
        else if (startValue !== portfolioModel.startDate)
            portfolioModel.setStartDate(startValue)

        if (endValue.length === 0)
            endDateInput.text = portfolioModel.endDate
        else if (endValue !== portfolioModel.endDate)
            portfolioModel.setEndDate(endValue)
    }

    function commitBudgetInput() {
        var budgetValue = budgetInput.text.trim()
        if (budgetValue.length === 0) {
            budgetInput.text = portfolioModel.budget.toFixed(0)
            return
        }

        var parsedBudget = parseFloat(budgetValue)
        if (!isFinite(parsedBudget) || parsedBudget <= 0) {
            budgetInput.text = portfolioModel.budget.toFixed(0)
            return
        }

        if (parsedBudget !== portfolioModel.budget)
            portfolioModel.setBudget(parsedBudget)
    }

    function commitInputs() {
        portfolioModel.commitInputs(
            assetInput.text,
            startDateInput.text,
            endDateInput.text,
            budgetInput.text
        )

        assetInput.text = portfolioModel.selectedTickers.join(", ")
        startDateInput.text = portfolioModel.startDate
        endDateInput.text = portfolioModel.endDate
        budgetInput.text = portfolioModel.budget.toFixed(0)
    }

    Connections {
        target: portfolioModel

        function onAssetsChanged() {
            assetInput.text = portfolioModel.selectedTickers.join(", ")
        }

        function onSettingsChanged() {
            startDateInput.text = portfolioModel.startDate
            endDateInput.text = portfolioModel.endDate
            budgetInput.text = portfolioModel.budget.toFixed(0)
        }
    }

    Flickable {
        anchors.fill: parent
        contentHeight: contentColumn.implicitHeight + 40
        clip: true
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        Column {
            id: contentColumn
            anchors { left: parent.left; right: parent.right; top: parent.top }
            anchors.margins: 28
            spacing: 22

            PageHeader {
                title: "User Input"
                subtitle: "Set portfolio assets, time range, and budget before running optimization"
                badgeText: "INPUT"
                badgeColor: "#ffb347"
            }

            Rectangle {
                width: parent.width
                height: assetColumn.implicitHeight + 32
                color: "#0f1018"
                border.color: "#2a2d45"
                radius: 12

                Column {
                    id: assetColumn
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 14

                    Text {
                        text: "ASSETS"
                        font.pixelSize: 10
                        font.letterSpacing: 1.5
                        color: "#4a5068"
                    }

                    Text {
                        text: "Enter comma-separated symbols such as AAPL, MSFT, GOOGL."
                        font.pixelSize: 12
                        color: "#8892b0"
                    }

                    Rectangle {
                        width: parent.width
                        height: 44
                        radius: 10
                        color: "#161822"
                        border.color: assetInput.activeFocus ? "#00d4ff" : "#2a2d45"
                        border.width: assetInput.activeFocus ? 1.5 : 1

                        TextInput {
                            id: assetInput
                            anchors.fill: parent
                            anchors.margins: 12
                            text: portfolioModel.selectedTickers.join(", ")
                            color: "#e8eaf6"
                            font.pixelSize: 13
                            selectByMouse: true
                            verticalAlignment: Text.AlignVCenter
                            onEditingFinished: root.commitAssetInput()
                            onActiveFocusChanged: if (!activeFocus) root.commitAssetInput()
                        }
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
                                width: tickerLabel.width + 20
                                height: 30
                                radius: 15
                                color: selected ? "#0f2430" : "#161822"
                                border.color: selected ? "#00d4ff" : "#2a2d45"
                                border.width: selected ? 1.5 : 1

                                Text {
                                    id: tickerLabel
                                    anchors.centerIn: parent
                                    text: modelData
                                    font.pixelSize: 11
                                    font.weight: selected ? Font.DemiBold : Font.Normal
                                    color: selected ? "#00d4ff" : "#8892b0"
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (selected)
                                            portfolioModel.removeTicker(modelData)
                                        else
                                            portfolioModel.addTicker(modelData)
                                        assetInput.text = portfolioModel.selectedTickers.join(", ")
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: formColumn.implicitHeight + 32
                color: "#0f1018"
                border.color: "#2a2d45"
                radius: 12

                Column {
                    id: formColumn
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 18

                    Text {
                        text: "PORTFOLIO SETTINGS"
                        font.pixelSize: 10
                        font.letterSpacing: 1.5
                        color: "#4a5068"
                    }

                    Row {
                        width: parent.width
                        spacing: 14

                        Column {
                            width: (parent.width - 28) / 3
                            spacing: 8

                            Text {
                                text: "Start Date"
                                font.pixelSize: 12
                                color: "#8892b0"
                            }

                            Rectangle {
                                width: parent.width
                                height: 42
                                radius: 10
                                color: "#161822"
                                border.color: startDateInput.activeFocus ? "#00d4ff" : "#2a2d45"

                                TextInput {
                                    id: startDateInput
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    text: portfolioModel.startDate
                                    color: "#e8eaf6"
                                    font.pixelSize: 13
                                    selectByMouse: true
                                    verticalAlignment: Text.AlignVCenter
                                    onEditingFinished: root.commitDateInputs()
                                    onActiveFocusChanged: if (!activeFocus) root.commitDateInputs()
                                }
                            }
                        }

                        Column {
                            width: (parent.width - 28) / 3
                            spacing: 8

                            Text {
                                text: "End Date"
                                font.pixelSize: 12
                                color: "#8892b0"
                            }

                            Rectangle {
                                width: parent.width
                                height: 42
                                radius: 10
                                color: "#161822"
                                border.color: endDateInput.activeFocus ? "#00d4ff" : "#2a2d45"

                                TextInput {
                                    id: endDateInput
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    text: portfolioModel.endDate
                                    color: "#e8eaf6"
                                    font.pixelSize: 13
                                    selectByMouse: true
                                    verticalAlignment: Text.AlignVCenter
                                    onEditingFinished: root.commitDateInputs()
                                    onActiveFocusChanged: if (!activeFocus) root.commitDateInputs()
                                }
                            }
                        }

                        Column {
                            width: (parent.width - 28) / 3
                            spacing: 8

                            Text {
                                text: "Budget ($)"
                                font.pixelSize: 12
                                color: "#8892b0"
                            }

                            Rectangle {
                                width: parent.width
                                height: 42
                                radius: 10
                                color: "#161822"
                                border.color: budgetInput.activeFocus ? "#00d4ff" : "#2a2d45"

                                TextInput {
                                    id: budgetInput
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    text: portfolioModel.budget.toFixed(0)
                                    color: "#e8eaf6"
                                    font.pixelSize: 13
                                    selectByMouse: true
                                    validator: DoubleValidator { bottom: 1.0 }
                                    verticalAlignment: Text.AlignVCenter
                                    onEditingFinished: root.commitBudgetInput()
                                    onActiveFocusChanged: if (!activeFocus) root.commitBudgetInput()
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: "#1e2030"
                    }

                    Text {
                        text: "Current run will use " + portfolioModel.selectedTickers.length + " assets from " + portfolioModel.startDate + " to " + portfolioModel.endDate + " with a $" + portfolioModel.budget.toFixed(0) + " budget."
                        font.pixelSize: 12
                        color: "#e8eaf6"
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }

                    Text {
                        text: "Tip: After updating the inputs, use the Optimize Now button in the sidebar to refresh all portfolio tabs."
                        font.pixelSize: 12
                        color: "#4a5068"
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                }
            }
        }
    }
}
