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
        color: colorDarkest
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        // Title row
        RowLayout {
            Layout.fillWidth: true

            Label {
                text: "My Boards"
                font.pixelSize: 28
                font.bold: true
                color: colorLight
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }
        }

        // New board input + button
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            TextField {
                id: newBoardName
                Layout.fillWidth: true
                placeholderText: "New board name"
                color: colorLight
                placeholderTextColor: colorMedium

                background: Rectangle {
                    radius: radius
                    color: colorDark
                    border.color: colorMedium
                    border.width: 1
                }
            }

            Button {
                text: "New Board"
                Layout.preferredWidth: 140

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

        // Boards list
        Frame {
            Layout.fillWidth: true
            Layout.fillHeight: true
            padding: 12

            background: Rectangle {
                radius: radius
                color: colorDark
                border.color: "#1E141F"
                border.width: 1
            }

            ListView {
                id: boardsList
                anchors.fill: parent
                clip: true
                spacing: 10
                model: boardManager.boards

                delegate: Frame {
                    width: ListView.view.width
                    padding: 12

                    background: Rectangle {
                        radius: radius
                        color: colorDarkest
                        border.color: "#221824"
                        border.width: 1
                    }

                    RowLayout {
                        anchors.fill: parent
                        spacing: 12

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Label {
                                text: modelData.name
                                font.pixelSize: 20
                                color: colorLight
                            }

                            Label {
                                text: modelData.noteCount + " notes"
                                font.pixelSize: 12
                                color: "#B9A8B7"
                            }
                        }

                        Button {
                            text: "Open"

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
                                boardManager.selectBoard(modelData.id)
                                root.openBoardRequested(modelData.id)
                            }
                        }

                        Button {
                            text: "Delete"

                            contentItem: Label {
                                text: parent.text
                                color: colorLight
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                radius: radius
                                color: "#b00020"
                            }

                            onClicked: boardManager.deleteBoard(modelData.id)
                        }
                    }
                }

                ScrollBar.vertical: ScrollBar { }
            }
        }
    }
}
