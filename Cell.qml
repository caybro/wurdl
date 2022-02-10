import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import org.caybro.wurdl 1.0

Rectangle {
    id: root
    width: 55
    height: 60
    radius: 6
    border.width: 2
    border.color: Positioner.index === game.currentIndex ? Material.accent : "black"
    Behavior on border.color { ColorAnimation {} }
    color: "aliceblue"
    Behavior on color { ColorAnimation {} }

    //readonly property int row: Positioner.index / Wurdl.totalColumns
    //readonly property int column: Positioner.index % Wurdl.totalColumns

    property alias letter: label.text

    Label {
        id: label
        anchors.centerIn: parent
        font.capitalization: Font.AllUppercase
        //text: "%1,%2".arg(root.row).arg(root.column)
        font.pixelSize: Qt.application.font.pixelSize * 1.6
    }
}
