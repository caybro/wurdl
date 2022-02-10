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
    // TODO
    Material.background: "aliceblue"

    enabled: {
        if (text === game.checkSymbol) {
            return game.currentIndex > 0 && game.currentIndex % Wurdl.totalColumns === 0 && game.currentIndex <= Wurdl.totalCells;
        } else if (text === game.deleteSymbol) {
            return game.currentIndex > 0 && game.currentIndex <= Wurdl.totalCells;
        }

        // enable letters only when the last line got accepted (thus incrementing the currentRow)
        return Math.trunc(game.currentIndex/Wurdl.totalColumns) <= game.currentRow
    }

    onClicked: root.letterPressed(text)
}
