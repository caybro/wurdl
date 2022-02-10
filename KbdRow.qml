import QtQuick 2.15
import QtQuick.Layouts 1.15

Row {
    id: root

    property alias model: repeater.model

    signal letterPressed(string letter)

    Layout.alignment: Qt.AlignHCenter
    spacing: 8
    Repeater {
        id: repeater
        KbdLetter {
            onLetterPressed: root.letterPressed(letter)
        }
    }
}
