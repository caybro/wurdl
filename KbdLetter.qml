import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import org.caybro.wurdl 1.0

Button {
    id: root
    implicitWidth: text ? 30 : 50
    text: typeof modelData !== 'undefined' ? modelData : ""
    font.pixelSize: Qt.application.font.pixelSize * 1.1

    readonly property color exactMatchColor: Material.color(Material.Green)
    readonly property color partialMatchColor: Material.color(Material.Orange)
    readonly property color noMatchColor: Material.color(Material.Grey)

    signal letterPressed(string letter)

    // bg color
    Material.background: {
        if (text) {
            if (game.exactMatchingLetters.includes(root.text))
                return exactMatchColor;
            else if (game.partiallyMatchingLetters.includes(root.text))
                return partialMatchColor;
            else if (game.usedLetters.includes(root.text))
                return noMatchColor;
        }
    }

    enabled: {
        if (game.gameOver) {
            return false;
        }

        // enable letters only when the last line got accepted (thus incrementing the currentRow)
        return Math.trunc(game.currentIndex/Wurdl.totalColumns) <= game.currentRow
    }

    onClicked: {
        if (text)
            root.letterPressed(text);
    }
}
