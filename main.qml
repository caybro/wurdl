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

    header: ToolBar {
        RowLayout {
            width: parent.width
            Label {
                //Layout.fillWidth: true
                anchors.centerIn: parent
                horizontalAlignment: Label.AlignHCenter
                elide: Label.ElideMiddle
                text: qsTr("Game number %1").arg(Wurdl.todaysWordIndex+1)
                font.pixelSize: Qt.application.font.pixelSize * 1.5
            }

            ToolButton {
                Layout.alignment: Qt.AlignRight
                icon.source: "qrc:/icons/outline_restart_alt_black_24dp.png"
                font.pixelSize: Qt.application.font.pixelSize * 1.5
                onClicked: game.newGame()
                ToolTip.text: qsTr("Restart Game")
                ToolTip.visible: hovered
            }
        }
    }

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

    Dialog {
        id: dlg
        anchors.centerIn: Overlay.overlay
        modal: true
        standardButtons: Dialog.Ok
        property alias text: dlgLabel.text
        Label {
            id: dlgLabel
            anchors.centerIn: parent
        }
    }

    QtObject {
        id: game
        readonly property string checkSymbol: "✔"
        readonly property string deleteSymbol: "⌫"

        property int currentRow: 0
        onCurrentRowChanged: {
            console.info("Current row changed:", currentRow)
            Qt.callLater(recalcMatchingLetters);
        }

        property int currentIndex: 0
        onCurrentIndexChanged: {
            console.info("Current index:", currentIndex);
        }

        readonly property bool gameOver: gameWon || gameLost
        property bool gameWon
        property bool gameLost

        property var exactMatchingLetters: []
        property var partiallyMatchingLetters: []
        property var usedLetters: []

        function recalcMatchingLetters() {
            var exactMatches = [];
            var partialMatches = [];
            var otherLetters = []
            for (let i = 0; i < currentIndex; i++) {
                const cell = gameGridRepeater.itemAt(i);
                //console.info("!!! CHECKING CELL FOR MATCHES:", i);
                if (cell.hasExactMatch && !exactMatches.includes(cell.letter)) {
                    //console.info("!!! EXACT:", cell.letter);
                    exactMatches.push(cell.letter);
                } else if (cell.hasPartialMatch && !partialMatches.includes(cell.letter)) {
                    //console.info("!!! PARTIAL:", cell.letter);
                    partialMatches.push(cell.letter);
                } else if (!otherLetters.includes(cell.letter)) {
                    otherLetters.push(cell.letter);
                }
            }
            console.info("Exact matching kbd letters:", exactMatches);
            console.info("Partially matching kbd letters:", partialMatches);
            console.info("Other used kbd letters:", otherLetters);
            exactMatchingLetters = exactMatches;
            partiallyMatchingLetters = partialMatches;
            usedLetters = otherLetters;
        }

        function newGame() {
            for (let i = 0; i < currentIndex; i++) {
                gameGridRepeater.itemAt(i).letter = "";
            }
            currentIndex = 0;
            currentRow = 0;
            gameWon = false;
            gameLost = false;
            exactMatchingLetters = [];
            partiallyMatchingLetters = [];
            usedLetters.length = [];
        }

        function putLetter(index, letter) {
            gameGridRepeater.itemAt(currentIndex).letter = letter;
            currentIndex++;
        }

        function removeLastLetter() {
            currentIndex--;
            gameGridRepeater.itemAt(currentIndex).letter = "";
        }

        function currentRowWord() {
            var result = [];
            for (let i = 0; i < Wurdl.totalColumns; i++) {
                const cell = gameGridRepeater.itemAt(currentRow * Wurdl.totalColumns + i);
                result.push(cell.letter);
            }

            return result.join('');
        }

        function keyPressed(letter) {
            if (letter === checkSymbol) {
                console.info("!!! OK pressed")
                const cw = currentRowWord();
                console.info("!!! Checking current row:", currentRow, "; current row's word:", cw)

                if (cw === Wurdl.todaysGameWord) { // game won
                    currentRow++;
                    gameWon = true;
                    dlg.title = qsTr("Game Won!");
                    dlg.text = qsTr("Congratulations<br><br>" +
                                    "You won the game in %n turn(s)", "", currentRow);
                    dlg.open();
                    return;
                }

                const wordOk = Wurdl.checkWord(cw);
                console.info("!!! Current word in dictionary:", wordOk);
                if (wordOk) {
                    currentRow++;
                    if (currentRow >= Wurdl.totalRows) { // game lost
                        gameLost = true;
                        dlg.title = qsTr("Game Lost :(");
                        dlg.text = qsTr("Unfortunately you couldn't make it this time<br>" +
                                        "The word was: '%1'").arg(Wurdl.todaysGameWord);
                        dlg.open();
                        return;
                    }
                } else {
                    console.warn("Current word not in the dictionary:", cw);
                    dlg.title = qsTr("Word Not Found");
                    dlg.text = qsTr("The word '%1' was not found in dictionary, try again.").arg(cw);
                    dlg.open();
                }
            } else if (letter === deleteSymbol) {
                console.info("!!! Delete pressed")
                removeLastLetter();
            } else {
                //console.info("!!! Letter pressed", letter)
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
