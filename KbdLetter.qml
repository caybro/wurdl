import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import org.caybro.wurdl 1.0

Button {
    id: root
    implicitWidth: 50
    text: modelData
    font.pixelSize: Qt.application.font.pixelSize * 1.4

    signal letterPressed(string letter)

    // font color
    Material.foreground: text === game.checkSymbol ? Material.color(Material.Green)
                                                   : (text === game.deleteSymbol ? Material.color(Material.Red) : Material.foreground)

    // bg color
    Material.background: {
        if (root.text !== game.checkSymbol && root.text !== game.deleteSymbol) {
            if (game.exactMatchingLetters.includes(root.text))
                return Material.color(Material.Green);
            else if (game.partiallyMatchingLetters.includes(root.text))
                return Material.color(Material.Orange);
            else if (game.usedLetters.includes(root.text))
                return Material.color(Material.Grey);
        }

        return "aliceblue";
    }

    enabled: {
        if (game.gameOver) {
            return false;
        } else  if (text === game.checkSymbol) {
            return game.currentIndex > game.currentRow * Wurdl.totalColumns && game.currentIndex % Wurdl.totalColumns === 0 && game.currentIndex <= Wurdl.totalCells;
        } else if (text === game.deleteSymbol) {
            return game.currentIndex > game.currentRow * Wurdl.totalColumns && game.currentIndex <= Wurdl.totalCells;
        }

        // enable letters only when the last line got accepted (thus incrementing the currentRow)
        return Math.trunc(game.currentIndex/Wurdl.totalColumns) <= game.currentRow
    }

    onClicked: root.letterPressed(text)
}
