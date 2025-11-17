// qmlgui/qml/AskAiPage.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: root

    property string boardId: ""
    title: "Ask AI"

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            ToolButton {
                text: "\u25C0 Back"
                onClicked: StackView.view.pop()
            }
            Label {
                text: "Ask AI about \"" + boardManager.currentBoardName + "\""
                font.pixelSize: 20
                Layout.alignment: Qt.AlignVCenter
            }
            Item { Layout.fillWidth: true }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        GroupBox {
            title: "Your question"
            Layout.fillWidth: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4

                TextArea {
                    id: questionInput
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
                    placeholderText: "Ask a question based on the notes in this board..."
                    wrapMode: TextArea.Wrap
                }

                RowLayout {
                    Layout.fillWidth: true
                    Item { Layout.fillWidth: true }

                    Button {
                        text: "Ask AI"
                        enabled: !studyController.isBusy
                        onClicked: {
                            studyController.askAiAboutBoard(boardId, questionInput.text)
                        }
                    }

                    BusyIndicator {
                        running: studyController.isBusy
                        visible: running
                    }
                }
            }
        }

        GroupBox {
            title: "AI answer"
            Layout.fillWidth: true
            Layout.fillHeight: true

            ScrollView {
                anchors.fill: parent
                Text {
                    id: answerText
                    anchors.margins: 8
                    text: studyController.lastAiAnswer.length > 0
                          ? studyController.lastAiAnswer
                          : "No answer yet. Ask a question above."
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    Component.onCompleted: {
        // optional: clear last answer when entering
        // studyController.clearLastAnswer() if you add such an API
    }
}
