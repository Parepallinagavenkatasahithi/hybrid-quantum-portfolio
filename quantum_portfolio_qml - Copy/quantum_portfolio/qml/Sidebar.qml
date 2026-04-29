import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#0f1018"
    property int currentIndex: 0
    signal optimizeRequested()

    property var navItems: [
        { icon: "📝", label: "User Input", index: 0 },
        { icon: "🏛️", label: "Classical Portfolio", index: 1 },
        { icon: "⚛️", label: "Qml Portfolio", index: 2 },
        { icon: "⚖️", label: "Comparison", index: 3 },
        { icon: "⚡", label: "Stress Test", index: 4 },
        { icon: "🔥", label: "Correlation Heatmap", index: 5 },
        { icon: "📡", label: "Beta-Market Tracker", index: 6 },
        { icon: "🤖", label: "AI chatbot", index: 7 },
        { icon: "⬇️", label: "Download", index: 8 }
    ]

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            height: 86
            color: "transparent"

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 4

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "QPO"
                    font.pixelSize: 24
                    font.weight: Font.Bold
                    font.letterSpacing: 6
                    color: "#00d4ff"
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "QML PORTFOLIO SUITE"
                    font.pixelSize: 8
                    font.letterSpacing: 2
                    color: "#4a5068"
                }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: "#2a2d45" }
        Item { Layout.preferredHeight: 14 }

        Repeater {
            model: root.navItems
            delegate: NavItem {
                Layout.fillWidth: true
                icon: modelData.icon
                label: modelData.label
                active: root.currentIndex === modelData.index
                onClicked: root.currentIndex = modelData.index
            }
        }

        Item { Layout.fillHeight: true }

        Rectangle {
            Layout.fillWidth: true
            Layout.margins: 16
            height: 46
            radius: 12
            color: runMouseArea.containsMouse ? "#00b8dd" : "#00d4ff"

            Behavior on color { ColorAnimation { duration: 150 } }

            Row {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    text: portfolioModel.isLoading ? "..." : ">"
                    font.pixelSize: 14
                    color: "#08090e"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: portfolioModel.isLoading ? "Running..." : "Optimize Now"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    color: "#08090e"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: runMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                enabled: !portfolioModel.isLoading
                onClicked: root.optimizeRequested()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            height: 4
            radius: 2
            color: "#1e2030"
            visible: portfolioModel.isLoading

            Rectangle {
                width: parent.width * portfolioModel.progress / 100
                height: parent.height
                radius: parent.radius
                color: "#00d4ff"
                Behavior on width { NumberAnimation { duration: 300 } }
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 6
            text: portfolioModel.isLoading
                  ? portfolioModel.status
                  : (portfolioModel.hasPendingChanges
                     ? "Inputs updated. Optimize to refresh."
                     : portfolioModel.dataSourceLabel)
            font.pixelSize: 10
            color: "#4a5068"
            wrapMode: Text.WordWrap
            width: parent.width - 28
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 14
            text: "v3.0 QML"
            font.pixelSize: 9
            font.letterSpacing: 1
            color: "#2a2d45"
        }
    }
}
