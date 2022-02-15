import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import org.caybro.wurdl 1.0

Rectangle {
    id: root
    width: 60
    height: 60
    radius: 6
    border.width: 2
    border.color: !game.gameOver && Positioner.index === game.currentIndex ? Material.accent
                                                                           : Material.foreground
    // highlight cell background based on matches against the current game word
    color: hasExactMatch ? game.exactMatchColor :
                           hasPartialMatch ? game.partialMatchColor
                                           : row < game.currentRow ? game.noMatchColor
                                                                   : "transparent"
    Behavior on color { ColorAnimation {} }

    readonly property int row: Positioner.index / Wurdl.totalColumns
    readonly property int column: Positioner.index % Wurdl.totalColumns

    property bool hasExactMatch
    property bool hasPartialMatch

    property alias letter: label.text

    Label {
        id: label
        anchors.centerIn: parent
        font.capitalization: Font.AllUppercase
        font.weight: Font.DemiBold
        font.pixelSize: Qt.application.font.pixelSize * 1.6
    }
}
