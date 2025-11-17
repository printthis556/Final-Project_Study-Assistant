// qmlgui/qml/BoardPage.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: root

    property string boardId: ""
    title: boardManager.currentBoardName

    // helper so back button uses the Page's StackView context
    function goBack() {
        if (StackView.view) {
            StackView.view.pop()
        }
    }

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            ToolButton {
                text: "\u25C0 Back"
                onClicked: root.goBack()
            }
            Label {
                text: boardManager.currentBoardName
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

        GroupBox {
            title: "Notes in this board"
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8

                ListView {
                    id: notesList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: boardManager.currentBoardNotes

                    delegate: Frame {
                        width: ListView.view.width
                        padding: 8
                        Column {
                            spacing: 4
                            Text {
                                text: modelData.preview
                                wrapMode: Text.WordWrap
                            }
                            Text {
                                text: "Full length: " + modelData.text.length + " chars"
                                color: "#888"
                                font.pixelSize: 10
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.RightButton
                            onClicked: {
                                if (mouse.button === Qt.RightButton) {
                                    boardManager.deleteNoteFromCurrentBoard(modelData.index)
                                }
                            }
                        }
                    }

                    ScrollBar.vertical: ScrollBar { }
                }

                GroupBox {
                    title: "Add note"
                    Layout.fillWidth: true

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 4

                        TextArea {
                            id: noteInput
                            Layout.fillWidth: true
                            Layout.preferredHeight: 120
                            wrapMode: TextArea.Wrap
                            placeholderText: "Paste or type notes here..."
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Item { Layout.fillWidth: true }

                            Button {
                                text: "Add Note"
                                onClicked: {
                                    if (noteInput.text.trim().length === 0)
                                        return
                                    boardManager.addNoteToCurrentBoard(noteInput.text)
                                    noteInput.text = ""
                                }
                            }
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Button {
                text: "Study Flashcards"
                Layout.fillWidth: true
                enabled: boardManager.currentBoardNotes.length > 0
                onClicked: {
                    StackView.view.push("StudyFlashcardsPage.qml", {
                        "boardId": root.boardId
                    })
                }
            }

            Button {
                text: "Ask AI"
                Layout.fillWidth: true
                enabled: boardManager.currentBoardNotes.length > 0
                onClicked: {
                    StackView.view.push("AskAiPage.qml", {
                        "boardId": root.boardId
                    })
                }
            }
        }
    }

    Component.onCompleted: {
        if (boardId.length > 0)
            boardManager.selectBoard(boardId)
    }
}
