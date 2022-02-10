import QtQuick 2.15
import QtQuick.Layouts 1.15

Row {
    Layout.alignment: Qt.AlignHCenter
    id: root
    spacing: 6

    property alias model: repeater.model

    signal letterPressed(string letter)

    Repeater {
        id: repeater
        KbdLetter {
            onLetterPressed: root.letterPressed(letter)
        }
    }
}
