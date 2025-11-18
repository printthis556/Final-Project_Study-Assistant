// qmlgui/qml/AskAiPage.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: root

    property string boardId: ""
    // NEW: reference to the StackView that owns this page
    property var stackViewRef

    title: "Ask AI"

    // palette
    property color colorLight: "#EDE8ED"
    property color colorMedium: "#C5AAB9"
    property color colorDark: "#3A2C3B"
    property color colorDarkest: "#302531"
    property int radius: 12

    // helper to go back
    function goBack() {
        if (stackViewRef) {
            stackViewRef.pop()
        } else {
            console.warn("AskAiPage: stackViewRef not set, cannot go back");
        }
    }

    background: Rectangle {
        gradient: Gradient {
            GradientStop { position: 0; color: colorDarkest }
            GradientStop { position: 1; color: colorDark }
        }
    }

    header: ToolBar {
        background: Rectangle { color: colorDark; opacity: 0.95 }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 6
            spacing: 8

            ToolButton {
                text: "\u25C0 Back"
                onClicked: root.goBack()   // <-- call the helper

                contentItem: Label {
                    text: parent.text
                    color: colorLight
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                }
            }

            Label {
                text: "Ask AI"
                font.pixelSize: 22
                font.bold: true
                color: colorLight
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Frame {
            Layout.fillWidth: true
            padding: 12

            background: Rectangle {
                radius: radius
                color: colorDark
                border.color: colorMedium
                opacity: 0.95
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 8

                Label {
                    text: "Your question"
                    color: colorMedium
                    font.bold: true
                }

                TextArea {
                    id: questionInput
                    Layout.fillWidth: true
                    Layout.preferredHeight: 140
                    placeholderText: "Ask a question based on the notes in this board..."
                    wrapMode: TextArea.Wrap
                    color: colorLight
                    placeholderTextColor: colorMedium

                    background: Rectangle {
                        radius: radius
                        color: colorDarkest
                        border.color: colorMedium
                        opacity: 0.9
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Item { Layout.fillWidth: true }

                    BusyIndicator {
                        running: studyController.isBusy
                        visible: running
                    }

                    Button {
                        text: "Ask AI"
                        enabled: !studyController.isBusy

                        contentItem: Label {
                            text: parent.text
                            color: colorDarkest
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                        }

                        background: Rectangle {
                            radius: radius
                            color: colorMedium
                            border.color: colorLight
                            border.width: 1
                        }

                        onClicked: {
                            studyController.askAiAboutBoard(boardId, questionInput.text)
                        }
                    }
                }
            }
        }

        Frame {
            Layout.fillWidth: true
            Layout.fillHeight: true
            padding: 12

            background: Rectangle {
                radius: radius
                color: colorDark
                border.color: colorMedium
                opacity: 0.95
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 8

                Label {
                    text: "AI answer"
                    color: colorMedium
                    font.bold: true
                }

                ScrollView {
                    anchors.fill: parent
                    clip: true

                    Text {
                        id: answerText
                        anchors.margins: 8
                        width: parent.width - 16
                        text: studyController.lastAiAnswer.length > 0
                              ? studyController.lastAiAnswer
                              : "No answer yet. Ask a question above."
                        wrapMode: Text.WordWrap
                        color: colorLight
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        // optional: clear last answer when entering
        // studyController.clearLastAnswer()
    }
}
