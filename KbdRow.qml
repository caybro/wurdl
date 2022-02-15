import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

import org.caybro.wurdl 1.0

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
            Material.foreground: Material.color(Material.Green)
            icon.source: "qrc:/icons/outline_done_black_24dp.png"
            enabled: game.currentIndex > game.currentRow * Wurdl.totalColumns && game.currentIndex % Wurdl.totalColumns === 0 && game.currentIndex <= Wurdl.totalCells
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
        sourceComponent: KbdLetter {
            Material.foreground: Material.color(Material.Red)
            icon.source: "qrc:/icons/outline_backspace_black_24dp.png"
            enabled: game.currentIndex > game.currentRow * Wurdl.totalColumns && game.currentIndex <= Wurdl.totalCells
            onClicked: root.deletePressed()
        }
    }
}
