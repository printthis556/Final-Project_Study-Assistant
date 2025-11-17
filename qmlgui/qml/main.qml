import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: root
    visible: true
    width: 900
    height: 600
    title: "Study Assistant"

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: MyBoardsPage {
            onOpenBoardRequested: function(boardId) {
                stackView.push("BoardPage.qml", { boardId: boardId })
            }
        }
    }

    // Simple error dialog instead of Snackbar
    Dialog {
        id: errorDialog
        modal: true
        title: "Error"
        standardButtons: Dialog.Ok
        x: (parent ? (parent.width - width) / 2 : 200)
        y: (parent ? (parent.height - height) / 2 : 200)

        property string message: ""

        contentItem: Text {
            text: errorDialog.message
            wrapMode: Text.WordWrap
            padding: 16
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

