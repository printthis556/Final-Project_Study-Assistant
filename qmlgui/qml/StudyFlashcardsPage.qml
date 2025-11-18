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
                onClicked: root.goBack()

                contentItem: Label {
                    text: parent.text
                    color: colorLight
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                }
            }

            Label {
                text: "Study Flashcards"
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

        // Top row: board name + regenerate
        Frame {
            Layout.fillWidth: true
            padding: 12

            background: Rectangle {
                radius: radius
                color: colorDark
                border.color: colorMedium
                opacity: 0.95
            }

            RowLayout {
                anchors.fill: parent
                spacing: 10

                ColumnLayout {
                    spacing: 2

                    Label {
                        text: "Board"
                        color: colorMedium
                        font.pixelSize: 11
                    }

                    Label {
                        text: boardManager.currentBoardName
                        color: colorLight
                        font.pixelSize: 16
                        font.bold: true
                    }
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
                        font.bold: true
                    }

                    background: Rectangle {
                        radius: radius
                        color: colorMedium
                        border.color: colorLight
                        border.width: 1
                    }

                    onClicked: {
                        studyController.generateFlashcardsForBoard(boardId)
                        currentIndex = 0
                    }
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
        Frame {
            Layout.fillWidth: true
            padding: 10

            background: Rectangle {
                radius: radius
                color: colorDark
                border.color: colorMedium
                opacity: 0.95
            }

            RowLayout {
                anchors.fill: parent
                spacing: 10

                Button {
                    text: "Previous"
                    enabled: currentIndex > 0

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
                        font.bold: true
                    }

                    background: Rectangle {
                        radius: radius
                        color: colorMedium
                        border.color: colorLight
                        border.width: 1
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
                    font.bold: true
                }
            }
        }
    }

    // Card showing Q & A
    Component {
        id: cardComponent

        Frame {
            padding: 20

            background: Rectangle {
                radius: radius
                color: colorDark
                border.color: colorMedium
                opacity: 0.95
            }

            Column {
                anchors.fill: parent
                anchors.margins: 6
                spacing: 14

                Text {
                    text: studyController.flashcardModel.data(
                              studyController.flashcardModel.index(root.currentIndex, 0),
                              FlashcardModel.QuestionRole)
                    font.pixelSize: 22
                    font.bold: true
                    wrapMode: Text.WordWrap
                    color: colorLight
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: colorMedium
                    opacity: 0.25
                }

                Text {
                    text: studyController.flashcardModel.data(
                              studyController.flashcardModel.index(root.currentIndex, 0),
                              FlashcardModel.AnswerRole)
                    wrapMode: Text.WordWrap
                    color: colorLight
                    font.pixelSize: 15
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
