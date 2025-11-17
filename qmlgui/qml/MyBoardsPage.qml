// qmlgui/qml/MyBoardsPage.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    signal openBoardRequested(string boardId)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        RowLayout {
            Layout.fillWidth: true
            Label {
                text: "My Boards"
                font.pixelSize: 28
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }

            Button {
                text: "New Board"
                onClicked: {
                    var name = newBoardName.text.trim()
                    if (name === "")
                        name = "Untitled Board"
                    var id = boardManager.createBoard(name)
                    newBoardName.text = ""
                    boardManager.selectBoard(id)
                    root.openBoardRequested(id)
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            TextField {
                id: newBoardName
                Layout.fillWidth: true
                placeholderText: "New board name"
            }
        }

        ListView {
            id: boardList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8
            model: boardManager.boards

            delegate: Frame {
                width: ListView.view.width
                height: implicitHeight
                padding: 12

                RowLayout {
                    anchors.fill: parent
                    spacing: 12

                    ColumnLayout {
                        Layout.fillWidth: true
                        Label {
                            text: modelData.name
                            font.pixelSize: 20
                        }
                        Label {
                            text: modelData.noteCount + " notes"
                            color: "#888"
                            font.pixelSize: 12
                        }
                    }

                    Button {
                        text: "Open"
                        onClicked: {
                            boardManager.selectBoard(modelData.id)
                            root.openBoardRequested(modelData.id)
                        }
                    }

                    Button {
                        text: "Delete"
                        background: Rectangle {
                            color: "#b00020"
                            radius: 4
                        }
                        onClicked: boardManager.deleteBoard(modelData.id)
                    }
                }
            }

            ScrollBar.vertical: ScrollBar { }
        }
    }
}
