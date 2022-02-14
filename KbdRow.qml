import QtQuick 2.15
import QtQuick.Layouts 1.15

Row {
    Layout.alignment: Qt.AlignHCenter
    id: root
    spacing: 5

    property alias model: repeater.model
    property bool specialButtons

    signal letterPressed(string letter)
    signal checkPressed()
    signal deletePressed()

    Loader {
        active: root.specialButtons
        sourceComponent: KbdLetter {
            checkButton: true
            icon.source: "qrc:/icons/outline_done_black_24dp.png"
            onClicked: root.checkPressed()
        }
    }
    Repeater {
        id: repeater
        KbdLetter {
            onLetterPressed: root.letterPressed(letter)
        }
    }
    Loader {
        active: root.specialButtons
        sourceComponent:  KbdLetter {
            deleteButton: true
            icon.source: "qrc:/icons/outline_backspace_black_24dp.png"
            onClicked: root.deletePressed()
        }
    }
}
