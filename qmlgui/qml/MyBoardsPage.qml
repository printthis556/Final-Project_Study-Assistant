// qmlgui/qml/MyBoardsPage.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    signal openBoardRequested(string boardId)

    // palette
    property color colorLight: "#EDE8ED"
    property color colorMedium: "#C5AAB9"
    property color colorDark: "#3A2C3B"
    property color colorDarkest: "#302531"
    property int radius: 12

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0; color: colorDarkest }
            GradientStop { position: 1; color: colorDark }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20

        // Title row
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            ColumnLayout {
                spacing: 4

                Label {
                    text: "IDEABOARD+"
                    font.pixelSize: 30
                    font.bold: true
                    color: colorLight
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                }

                Label {
                    text: "MyBoards"
                    color: colorMedium
                    font.pixelSize: 14
                }
            }

            Item { Layout.fillWidth: true }
        }

        // New board input + button
        Frame {
            Layout.fillWidth: true
            padding: 14

            background: Rectangle {
                radius: radius
                color: colorDark
                border.color: colorMedium
                opacity: 0.9
            }

            RowLayout {
                anchors.fill: parent
                spacing: 12

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Label {
                        text: "Create a new board"
                        color: colorLight
                        font.pixelSize: 14
                        font.bold: true
                    }

                    TextField {
                        id: newBoardName
                        Layout.fillWidth: true
                        placeholderText: "Name your board"
                        color: colorLight
                        placeholderTextColor: colorMedium
                        selectByMouse: true

                        background: Rectangle {
                            radius: radius
                            color: colorDarkest
                            border.color: colorMedium
                            border.width: 1
                            opacity: 0.85
                        }
                    }
                }

                Button {
                    text: "New Board"
                    Layout.preferredWidth: 150
                    padding: 12

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
        }

        // Boards list
        Frame {
            Layout.fillWidth: true
            Layout.fillHeight: true
            padding: 16

            background: Rectangle {
                radius: radius
                color: colorDark
                border.color: "#1E141F"
                border.width: 1
                opacity: 0.95
            }

            ListView {
                id: boardsList
                anchors.fill: parent
                clip: true
                spacing: 12
                model: boardManager.boards

                delegate: Frame {
                    width: ListView.view.width
                    padding: 14

                    background: Rectangle {
                        radius: radius
                        color: colorDarkest
                        border.color: "#221824"
                        border.width: 1
                        opacity: 0.9
                    }

                    RowLayout {
                        anchors.fill: parent
                        spacing: 12

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Label {
                                text: modelData.name
                                font.pixelSize: 20
                                font.bold: true
                                color: colorLight
                            }

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: colorMedium
                                opacity: 0.25
                            }

                            Label {
                                text: modelData.noteCount + " notes"
                                font.pixelSize: 12
                                color: colorMedium
                            }
                        }

                        ColumnLayout {
                            spacing: 8

                            Button {
                                text: "Open"
                                Layout.preferredWidth: 120

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
                                    boardManager.selectBoard(modelData.id)
                                    root.openBoardRequested(modelData.id)
                                }
                            }

                            Button {
                                text: "Delete"
                                Layout.preferredWidth: 120

                                contentItem: Label {
                                    text: parent.text
                                    color: colorLight
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.bold: true
                                }

                                background: Rectangle {
                                    radius: radius
                                    color: "#b00020"
                                }

                                onClicked: boardManager.deleteBoard(modelData.id)
                            }
                        }
                    }
                }

                ScrollBar.vertical: ScrollBar { }
            }
        }
    }
}
