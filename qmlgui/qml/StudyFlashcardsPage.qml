// qmlgui/qml/StudyFlashcardsPage.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: root

    property string boardId: ""
    title: "Study Flashcards"

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            ToolButton {
                text: "\u25C0 Back"
                onClicked: StackView.view.pop()
            }
            Label {
                text: "Study Flashcards"
                font.pixelSize: 22
                Layout.alignment: Qt.AlignVCenter
            }
            Item { Layout.fillWidth: true }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            Label {
                text: "Board: " + boardManager.currentBoardName
            }
            Item { Layout.fillWidth: true }
            BusyIndicator {
                running: studyController.isBusy
                visible: running
            }
            Button {
                text: "Regenerate"
                enabled: !studyController.isBusy
                onClicked: {
                    studyController.generateFlashcardsForBoard(boardId)
                }
            }
        }

        // Simple "one card at a time" viewer
        Loader {
            id: cardLoader
            Layout.fillWidth: true
            Layout.fillHeight: true

            sourceComponent: studyController.flashcardModel.rowCount > 0 ? cardComponent : emptyComponent
        }

        RowLayout {
            Layout.fillWidth: true

            Button {
                text: "Previous"
                enabled: studyController.flashcardModel.rowCount > 0 && currentIndex > 0
                onClicked: currentIndex--
            }
            Button {
                text: "Next"
                enabled: studyController.flashcardModel.rowCount > 0 && currentIndex < studyController.flashcardModel.rowCount - 1
                onClicked: currentIndex++
            }

            Item { Layout.fillWidth: true }

            Label {
                text: studyController.flashcardModel.rowCount > 0
                      ? (currentIndex + 1) + " / " + studyController.flashcardModel.rowCount
                      : "No flashcards"
            }
        }
    }

    property int currentIndex: 0

    Component {
        id: cardComponent

        Frame {
            padding: 16
            Column {
                spacing: 12

                Text {
                    text: studyController.flashcardModel.data(
                              studyController.flashcardModel.index(root.currentIndex, 0),
                              FlashcardModel.QuestionRole)
                    font.pixelSize: 20
                    wrapMode: Text.WordWrap
                }

                Rectangle {
                    height: 1
                    width: parent.width
                    color: "#ccc"
                }

                Text {
                    text: studyController.flashcardModel.data(
                              studyController.flashcardModel.index(root.currentIndex, 0),
                              FlashcardModel.AnswerRole)
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    Component {
        id: emptyComponent
        Label {
            text: "No flashcards yet.\n\nMake sure this board has notes, then press Regenerate."
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    Component.onCompleted: {
        studyController.generateFlashcardsForBoard(boardId)
        currentIndex = 0
    }
}
