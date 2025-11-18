// qmlgui/qml/StudyFlashcardsPage.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: root

    property string boardId: ""
    property var stackViewRef
    title: "Study Flashcards"

    // palette
    property color colorLight: "#EDE8ED"
    property color colorMedium: "#C5AAB9"
    property color colorDark: "#3A2C3B"
    property color colorDarkest: "#302531"
    property int radius: 12

    property int currentIndex: 0

    // helper for back navigation
    function goBack() {
        if (stackViewRef) {
            stackViewRef.pop()
        } else {
            console.warn("StudyFlashcardsPage: stackViewRef not set, cannot go back");
        }
    }

    background: Rectangle {
        color: colorDarkest
    }

    header: ToolBar {
        background: Rectangle { color: colorDark }

        RowLayout {
            anchors.fill: parent

            ToolButton {
                text: "\u25C0 Back"
                onClicked: root.goBack()

                contentItem: Label {
                    text: parent.text
                    color: colorLight
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Label {
                text: "Study Flashcards"
                font.pixelSize: 20
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

        // Top row: board name + regenerate
        RowLayout {
            Layout.fillWidth: true

            Label {
                text: "Board: " + boardManager.currentBoardName
                color: colorLight
            }

            Item { Layout.fillWidth: true }

            BusyIndicator {
                running: studyController.isBusy
                visible: running
            }

            Button {
                text: "Regenerate"
                enabled: !studyController.isBusy

                contentItem: Label {
                    text: parent.text
                    color: colorDarkest
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: radius
                    color: colorMedium
                }

                onClicked: {
                    studyController.generateFlashcardsForBoard(boardId)
                    currentIndex = 0
                }
            }
        }

        // Card area
        Loader {
            id: cardLoader
            Layout.fillWidth: true
            Layout.fillHeight: true

            sourceComponent: studyController.flashcardModel.rowCount > 0
                             ? cardComponent
                             : emptyComponent
        }

        // Navigation row
        RowLayout {
            Layout.fillWidth: true

            Button {
                text: "Previous"
                enabled: currentIndex > 0

                contentItem: Label {
                    text: parent.text
                    color: colorDarkest
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: radius
                    color: colorMedium
                }

                onClicked: {
                    if (currentIndex > 0)
                        currentIndex--
                    cardLoader.sourceComponent = studyController.flashcardModel.rowCount > 0
                                                ? cardComponent : emptyComponent
                }
            }

            Button {
                text: "Next"
                enabled: currentIndex < studyController.flashcardModel.rowCount - 1

                contentItem: Label {
                    text: parent.text
                    color: colorDarkest
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: radius
                    color: colorMedium
                }

                onClicked: {
                    if (currentIndex < studyController.flashcardModel.rowCount - 1)
                        currentIndex++
                    cardLoader.sourceComponent = studyController.flashcardModel.rowCount > 0
                                                ? cardComponent : emptyComponent
                }
            }

            Item { Layout.fillWidth: true }

            Label {
                text: studyController.flashcardModel.rowCount > 0
                      ? (currentIndex + 1) + " / " + studyController.flashcardModel.rowCount
                      : "No flashcards"
                color: colorLight
            }
        }
    }

    // Card showing Q & A
    Component {
        id: cardComponent

        Frame {
            padding: 16

            background: Rectangle {
                radius: radius
                color: colorDark
                border.color: colorMedium
            }

            Column {
                anchors.fill: parent
                anchors.margins: 4
                spacing: 12

                Text {
                    text: studyController.flashcardModel.data(
                              studyController.flashcardModel.index(root.currentIndex, 0),
                              FlashcardModel.QuestionRole)
                    font.pixelSize: 20
                    font.bold: true
                    wrapMode: Text.WordWrap
                    color: colorLight
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#4D3A4C"
                }

                Text {
                    text: studyController.flashcardModel.data(
                              studyController.flashcardModel.index(root.currentIndex, 0),
                              FlashcardModel.AnswerRole)
                    wrapMode: Text.WordWrap
                    color: colorLight
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
            color: colorLight
        }
    }

    Component.onCompleted: {
        studyController.generateFlashcardsForBoard(boardId)
        currentIndex = 0
    }
}
