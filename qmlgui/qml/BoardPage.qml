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
        gradient: Gradient {
            GradientStop { position: 0; color: colorDarkest }
            GradientStop { position: 1; color: colorDark }
        }
    }

    header: ToolBar {
        background: Rectangle {
            color: colorDark
            opacity: 0.95
        }

        RowLayout {
            anchors.fill: parent
            spacing: 10
            anchors.margins: 6

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

            ColumnLayout {
                spacing: 2

                Label {
                    text: boardManager.currentBoardName
                    font.pixelSize: 24
                    font.bold: true
                    color: colorLight
                    Layout.alignment: Qt.AlignVCenter
                }

                Label {
                    text: boardManager.currentBoardNotes.length + " notes available"
                    color: colorMedium
                    font.pixelSize: 12
                }
            }

            Item { Layout.fillWidth: true }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 14

        // NOTES LIST + ADD NOTE side by side
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 14

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
                    opacity: 0.95
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 10

                    ListView {
                        id: notesList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 8
                        model: boardManager.currentBoardNotes

                        delegate: Frame {
                            width: ListView.view.width
                            padding: 12

                            background: Rectangle {
                                radius: radius
                                color: colorDarkest
                                border.color: "#241A26"
                                opacity: 0.9
                            }

                            Column {
                                spacing: 6

                                Text {
                                    text: modelData.preview
                                    wrapMode: Text.WordWrap
                                    color: colorLight
                                    font.pixelSize: 14
                                }
                                Rectangle {
                                    width: parent.width
                                    height: 1
                                    color: colorMedium
                                    opacity: 0.2
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

            GroupBox {
                title: "Add note"
                Layout.preferredWidth: 320
                Layout.fillHeight: true

                label: Label {
                    text: addNote.title
                    color: colorMedium
                    font.pixelSize: 14
                    font.bold: true
                }

                background: Rectangle {
                    radius: radius
                    color: colorDark
                    border.color: "#241A26"
                    opacity: 0.95
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    TextArea {
                        id: noteInput
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        wrapMode: TextArea.Wrap
                        placeholderText: "Paste or type notes here..."
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

                        Button {
                            id: addNote
                            text: "Add Note"
                            padding: 10

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

        // ACTION BUTTONS
        Frame {
            Layout.fillWidth: true
            padding: 12

            background: Rectangle {
                radius: radius
                color: colorDark
                border.color: colorMedium
                opacity: 0.9
            }

            RowLayout {
                anchors.fill: parent
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
                        font.bold: true
                    }

                    background: Rectangle {
                        radius: radius
                        color: colorMedium
                        border.color: colorLight
                        border.width: 1
                    }

                    onClicked: {
                        if (!stackViewRef)
                            return

                        stackViewRef.push("StudyFlashcardsPage.qml", {
                            "boardId": root.boardId,
                            stackViewRef: root.stackViewRef
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
                        font.bold: true
                    }

                    background: Rectangle {
                        radius: radius
                        color: colorMedium
                        border.color: colorLight
                        border.width: 1
                    }

                    onClicked: {
                            if (!root.stackViewRef)
                                return

                            root.stackViewRef.push("AskAiPage.qml", {
                                boardId: root.boardId,
                                stackViewRef: root.stackViewRef    // <-- pass the stack in
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
}
