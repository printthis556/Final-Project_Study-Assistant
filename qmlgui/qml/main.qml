import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: root
    visible: true
    width: 900
    height: 600
    title: "Study Assistant"

    // palette
    property color colorLight: "#EDE8ED"
    property color colorMedium: "#C5AAB9"
    property color colorDark: "#3A2C3B"
    property color colorDarkest: "#302531"
    property int radius: 12

    // background layer
    Rectangle {
        anchors.fill: parent
        color: colorDarkest
    }

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: MyBoardsPage {
            onOpenBoardRequested: function(boardId) {
                stackView.push("BoardPage.qml", {
                    "boardId": boardId,
                    "stackViewRef": stackView   // <-- pass the stackView down
                })
            }
        }
    }


    Dialog {
        id: errorDialog
        modal: true
        standardButtons: Dialog.Ok
        title: "Error"
        property alias message: messageLabel.text

        background: Rectangle {
            radius: radius
            color: colorDark
            border.color: colorMedium
            border.width: 1
        }

        contentItem: Label {
            id: messageLabel
            padding: 16
            wrapMode: Text.WordWrap
            color: colorLight
        }
    }

    Connections {
        target: studyController
        function onErrorOccurred(message) {
            errorDialog.message = message
            errorDialog.open()
        }
    }
}
