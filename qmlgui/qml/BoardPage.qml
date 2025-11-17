// qmlgui/qml/BoardPage.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: root

    property string boardId: ""
    property var stackViewRef
    title: boardManager.currentBoardName

    // palette
    property color colorLight: "#EDE8ED"
    property color colorMedium: "#C5AAB9"
    property color colorDark: "#3A2C3B"
    property color colorDarkest: "#302531"
    property int radius: 12

    // helper so back button uses the Page's StackView context
    function goBack() {
        if (stackViewRef) {
            stackViewRef.pop()
        }
    }

    background: Rectangle {
        color: colorDarkest
    }

    header: ToolBar {
        background: Rectangle {
            color: colorDark
        }

        RowLayout {
            anchors.fill: parent
            spacing: 8

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
                text: boardManager.currentBoardName
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

        // NOTES LIST
        GroupBox {
            title: "Notes in this board"
            Layout.fillWidth: true
            Layout.fillHeight: true

            label: Label {
                text: control.title
                color: colorMedium
                font.pixelSize: 14
                font.bold: true
            }

            background: Rectangle {
                radius: radius
                color: colorDark
                border.color: "#241A26"
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8

                ListView {
                    id: notesList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 8
                    model: boardManager.currentBoardNotes

                    delegate: Frame {
                        width: ListView.view.width
                        padding: 10

                        background: Rectangle {
                            radius: radius
                            color: colorDarkest
                            border.color: "#241A26"
                        }

                        Column {
                            spacing: 4

                            Text {
                                text: modelData.preview
                                wrapMode: Text.WordWrap
                                color: colorLight
                            }
                            Text {
                                text: "Full length: " + modelData.text.length + " chars"
                                color: "#B9A8B7"
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
            }
        }

        // ADD NOTE
        GroupBox {
            title: "Add note"
            Layout.fillWidth: true

            label: Label {
                text: control.title
                color: colorMedium
                font.pixelSize: 14
                font.bold: true
            }

            background: Rectangle {
                radius: radius
                color: colorDark
                border.color: "#241A26"
            }

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
                    color: colorLight
                    placeholderTextColor: colorMedium

                    background: Rectangle {
                        radius: radius
                        color: colorDarkest
                        border.color: colorMedium
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Item { Layout.fillWidth: true }

                    Button {
                        text: "Add Note"

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
                            if (noteInput.text.trim().length === 0)
                                return
                            boardManager.addNoteToCurrentBoard(noteInput.text)
                            noteInput.text = ""
                        }
                    }
                }
            }
        }

        // ACTION BUTTONS
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Button {
                text: "Study Flashcards"
                Layout.fillWidth: true
                enabled: boardManager.currentBoardNotes.length > 0

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
                    if (!stackViewRef)
                        return

                    stackViewRef.push("StudyFlashcardsPage.qml", {
                        "boardId": root.boardId
                    })
                }
            }

            Button {
                text: "Ask AI"
                Layout.fillWidth: true
                enabled: boardManager.currentBoardNotes.length > 0

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
                    if (!stackViewRef)
                        return

                    stackViewRef.push("AskAiPage.qml", {
                        "boardId": root.boardId
                    })
                }
            }
        }

        Component.onCompleted: {
            if (boardId.length > 0)
                boardManager.selectBoard(boardId)
        }
    }
}
