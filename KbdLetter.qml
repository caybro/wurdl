import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import org.caybro.wurdl 1.0

Button {
    id: root
    implicitWidth: 50
    text: modelData
    font.pixelSize: Qt.application.font.pixelSize * 1.4

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

        return true;
    }

    onClicked: root.letterPressed(text)

    signal letterPressed(string letter)
}
