import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import org.caybro.wurdl 1.0

Button {
    id: root
    implicitWidth: text ? 30 : 45
    text: typeof modelData !== 'undefined' ? modelData : ""
    font.pixelSize: Qt.application.font.pixelSize * 1.1

    readonly property color exactMatchColor: Material.color(Material.Green)
    readonly property color partialMatchColor: Material.color(Material.Orange)
    readonly property color noMatchColor: Material.color(Material.Grey)

    property bool checkButton
    property bool deleteButton

    signal letterPressed(string letter)

    // font color
    Material.foreground: checkButton ? Material.color(Material.Green)
                                     : deleteButton ? Material.color(Material.Red) : undefined

    // bg color
    Material.background: {
        if (!checkButton && !deleteButton) {
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
        } else if (checkButton) {
            return game.currentIndex > game.currentRow * Wurdl.totalColumns && game.currentIndex % Wurdl.totalColumns === 0 && game.currentIndex <= Wurdl.totalCells;
        } else if (deleteButton) {
            return game.currentIndex > game.currentRow * Wurdl.totalColumns && game.currentIndex <= Wurdl.totalCells;
        }

        // enable letters only when the last line got accepted (thus incrementing the currentRow)
        return Math.trunc(game.currentIndex/Wurdl.totalColumns) <= game.currentRow
    }

    onClicked: {
        if (text)
            root.letterPressed(text);
    }
}
