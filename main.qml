import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Qt.labs.settings 1.1

import org.caybro.wurdl 1.0

ApplicationWindow {
    id: root
    width: 600
    height: 800
    visible: true
    title: qsTr("Wurdl")

    Component.onCompleted: {
        console.info("!!! Today's word index:", Wurdl.todaysWordIndex)
        console.info("!!! Today's word:", Wurdl.todaysGameWord)
        console.info("!!! Random word:", Wurdl.randomGameWord())
        console.info("!!! Is today's word in dictionary?", Wurdl.checkWord(Wurdl.todaysGameWord))
    }

    Settings {
        property alias x: root.x
        property alias y: root.y
        property alias width: root.width
        property alias height: root.height
    }

    QtObject {
        id: game
        // TODO dictionary
        readonly property string currentGameWord: "zhasl"
        readonly property string checkSymbol: "✔"
        readonly property string deleteSymbol: "⌫"

        property int currentRow: 0
        property int currentIndex: 0
        onCurrentIndexChanged: {
            console.info("Current index:", currentIndex);
        }

        function newGame() {
            currentIndex = 0;
            currentRow = 0;
        }

        function putLetter(index, letter) {
            gameGridRepeater.itemAt(game.currentIndex).letter = letter;
            currentIndex++;
        }

        function removeLastLetter() {
            currentIndex--;
            gameGridRepeater.itemAt(currentIndex).letter = "";
        }

        function currentLineWord() {
            var result = [];
            for (let i = 0; i < Wurdl.totalColumns; i++) {
                const cell = gameGridRepeater.itemAt((game.currentRow+1) * i);
                result.push(cell.letter);
            }

            return result.join('');
        }

        function keyPressed(letter) {
            if (letter === checkSymbol) {
                console.info("!!! OK pressed")
                const cw = currentLineWord();
                console.info("!!! Checking current line:", cw)
                const wordOk = Wurdl.checkWord(cw);
                console.info("!!! Current word in dictionary:", wordOk)
            } else if (letter === deleteSymbol) {
                console.info("!!! Delete pressed")
                removeLastLetter();
            } else {
                console.info("!!! Letter pressed", letter)
                putLetter(currentIndex, letter);
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        // game grid
        Grid {
            id: gameGrid
            Layout.alignment: Qt.AlignHCenter
            rows: Wurdl.totalRows
            columns: Wurdl.totalColumns
            rowSpacing: 6
            columnSpacing: 6

            Repeater {
                id: gameGridRepeater
                model: Wurdl.totalCells

                Cell {}
            }
        }

        Item { Layout.fillHeight: true }

        // keyboard
        KbdRow {
            model: ["ě", "š", "č", "ř", "ž", "ý", "á", "í", "é", "ď", "ť"]
            onLetterPressed: game.keyPressed(letter)
        }
        KbdRow {
            model: ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "ú"]
            onLetterPressed: game.keyPressed(letter)
        }
        KbdRow {
            model: ["a", "s", "d", "f", "g", "h", "j", "k", "l", "ů", "ň"]
            onLetterPressed: game.keyPressed(letter)
        }
        KbdRow {
            model: [game.checkSymbol, "z", "x", "c", "v", "b", "n", "m", game.deleteSymbol]
            onLetterPressed: game.keyPressed(letter)
        }
    }
}
