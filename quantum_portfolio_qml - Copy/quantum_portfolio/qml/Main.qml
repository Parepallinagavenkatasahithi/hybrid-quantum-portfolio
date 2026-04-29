import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

ApplicationWindow {
    id: root
    visible: true
    width: 1380
    height: 860
    minimumWidth: 1100
    minimumHeight: 700
    title: "Quantum Portfolio Optimizer"
    color: "#08090e"
    property real pageZoom: 1.0

    // ── Global font / color tokens ──────────────────────────────
    QtObject {
        id: theme
        readonly property color bg0:      "#08090e"
        readonly property color bg1:      "#0f1018"
        readonly property color bg2:      "#161822"
        readonly property color bg3:      "#1e2030"
        readonly property color border:   "#2a2d45"
        readonly property color accent:   "#00d4ff"
        readonly property color accentDim:"#0099bb"
        readonly property color quantum:  "#b060ff"
        readonly property color quantumDim:"#7030cc"
        readonly property color green:    "#00e5a0"
        readonly property color amber:    "#ffb347"
        readonly property color red:      "#ff5555"
        readonly property color textPri:  "#e8eaf6"
        readonly property color textSec:  "#8892b0"
        readonly property color textHint: "#4a5068"
        readonly property int   radiusSm: 6
        readonly property int   radiusMd: 10
        readonly property int   radiusLg: 14
    }

    // ── Notification toast ──────────────────────────────────────
    Connections {
        target: portfolioModel
        function onErrorOccurred(msg) {
            toast.show(msg, true)
        }
        function onOptimizationComplete() {
            toast.show("Optimization complete!", false)
        }
    }

    // ── Layout ──────────────────────────────────────────────────
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Sidebar
        Sidebar {
            id: sidebar
            Layout.preferredWidth: 220
            Layout.fillHeight: true
            onOptimizeRequested: {
                var page = pageStack.item
                if (page && page.commitInputs)
                    page.commitInputs()
                portfolioModel.runOptimization()
            }
        }

        // Divider
        Rectangle {
            width: 1
            Layout.fillHeight: true
            color: theme.border
        }

        // Main content
        Rectangle {
            id: pageHost
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#08090e"

            Flickable {
                id: pageViewport
                anchors.fill: parent
                clip: true
                contentWidth: zoomContent.width * root.pageZoom
                contentHeight: zoomContent.height * root.pageZoom
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AsNeeded }
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                Item {
                    id: zoomContent
                    width: pageViewport.width
                    height: pageViewport.height
                    transform: Scale {
                        origin.x: 0
                        origin.y: 0
                        xScale: root.pageZoom
                        yScale: root.pageZoom
                    }

                    Loader {
                        id: pageStack
                        anchors.fill: parent
                        source: {
                            switch (sidebar.currentIndex) {
                            case 0: return "UserInputPage.qml"
                            case 1: return "ClassicalPage.qml"
                            case 2: return "QAOAPage.qml"
                            case 3: return "ComparisonPage.qml"
                            case 4: return "StressTestPage.qml"
                            case 5: return "HeatmapPage.qml"
                            case 6: return "BetaMarketTrackerPage.qml"
                            case 7: return "AIChatbotPage.qml"
                            case 8: return "DownloadPage.qml"
                            default: return "UserInputPage.qml"
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    onWheel: function(wheel) {
                        if (wheel.modifiers & Qt.ControlModifier) {
                            if (wheel.angleDelta.y > 0)
                                root.pageZoom = Math.min(2.5, root.pageZoom + 0.1)
                            else if (wheel.angleDelta.y < 0)
                                root.pageZoom = Math.max(0.75, root.pageZoom - 0.1)
                            wheel.accepted = true
                        } else {
                            wheel.accepted = false
                        }
                    }
                }
            }

        }
    }

    // ── Toast notification ──────────────────────────────────────
    ToastNotification { id: toast }
}
