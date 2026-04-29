import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    color: "#08090e"

    ListModel {
        id: conversationModel
    }

    function seedConversation() {
        if (conversationModel.count === 0) {
            conversationModel.append({
                role: "assistant",
                message: "Ask me about allocations, risk, return, correlation, or stress testing for this QML portfolio."
            })
        }
    }

    Component.onCompleted: seedConversation()

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
                title: "AI chatbot"
                subtitle: "A built-in portfolio explainer"
                badgeText: "ASSIST"
                badgeColor: "#00d4ff"
            }

            Rectangle {
                width: parent.width
                height: 420
                color: "#0f1018"
                border.color: "#2a2d45"
                radius: 12

                Column {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 16

                    Text {
                        text: "TRY: Which portfolio has lower risk? | What is the top allocation? | How should I explain the heatmap?"
                        wrapMode: Text.WordWrap
                        font.pixelSize: 12
                        color: "#4a5068"
                    }

                    ListView {
                        id: chatView
                        width: parent.width
                        height: 250
                        model: conversationModel
                        spacing: 10
                        clip: true

                        delegate: Rectangle {
                            width: chatView.width
                            height: Math.max(56, bubbleText.implicitHeight + 24)
                            color: "transparent"

                            Rectangle {
                                width: parent.width * 0.82
                                height: bubbleText.implicitHeight + 24
                                radius: 12
                                anchors.right: model.role === "user" ? parent.right : undefined
                                color: model.role === "user" ? "#10263a" : "#161822"
                                border.color: model.role === "user" ? "#00d4ff" : "#2a2d45"

                                Text {
                                    id: bubbleText
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    wrapMode: Text.WordWrap
                                    text: model.message
                                    font.pixelSize: 13
                                    color: "#e8eaf6"
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 98
                        radius: 12
                        color: "#11131c"
                        border.color: "#2a2d45"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            TextArea {
                                id: promptInput
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                wrapMode: TextEdit.Wrap
                                placeholderText: "Ask the assistant about this portfolio..."
                                color: "#e8eaf6"
                                background: null
                            }

                            Button {
                                text: "Send"
                                onClicked: {
                                    var prompt = promptInput.text.trim()
                                    if (prompt.length === 0)
                                        return
                                    conversationModel.append({ role: "user", message: prompt })
                                    conversationModel.append({ role: "assistant", message: portfolioModel.askAssistant(prompt) })
                                    promptInput.text = ""
                                    chatView.positionViewAtEnd()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
