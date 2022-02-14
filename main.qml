import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

import Qt.labs.settings 1.1

import org.caybro.wurdl 1.0

ApplicationWindow {
    id: root
    width: 600
    height: 800
    visible: true
    title: qsTr("Wurdl")

    header: ToolBar {
        Material.theme: Material.System
        RowLayout {
            width: parent.width
            ToolButton {
                Layout.alignment: Qt.AlignLeft
                icon.source: "qrc:/icons/outline_menu_black_24dp.png"
                ToolTip.text: qsTr("Menu")
                ToolTip.visible: hovered
                onClicked: menu.open()

                Menu {
                    y: parent.height
                    id: menu
                    MenuItem {
                        icon.source: "qrc:/icons/outline_casino_black_24dp.png"
                        text: qsTr("Random Game")
                        onClicked: game.newGame()
                    }
                    MenuItem {
                        icon.source: "qrc:/icons/outline_history_black_24dp.png"
                        text: qsTr("Previous Games...")
                        onClicked: prevGameDlg.open()
                    }
                    MenuSeparator {}
                    SwitchDelegate {
                        checkable: true
                        text: qsTr("Dark Mode")
                        checked: root.Material.theme === Material.Dark
                        onToggled: {
                            root.Material.theme = checked ? Material.Dark : Material.Light;
                        }
                    }
                }
            }
            Label {
                Layout.alignment: Qt.AlignCenter
                horizontalAlignment: Label.AlignHCenter
                elide: Label.ElideMiddle
                text: qsTr("Game number %1").arg(game.currentGameIndex+1)
                font.pixelSize: Qt.application.font.pixelSize * 1.5
            }
            ToolButton {
                Layout.alignment: Qt.AlignRight
                icon.source: "qrc:/icons/outline_restart_alt_black_24dp.png"
                onClicked: game.newGame(game.currentGameIndex)
                ToolTip.text: qsTr("Restart Game")
                ToolTip.visible: hovered
            }
        }
    }

    Settings {
        property alias x: root.x
        property alias y: root.y
        property alias width: root.width
        property alias height: root.height
        property alias lastHistoryGame: gameSelector.value
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

    Dialog {
        id: prevGameDlg
        anchors.centerIn: Overlay.overlay
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        title: qsTr("Play Previous Game")
        ColumnLayout {
            anchors.fill: parent
            Label {
                Layout.fillWidth: true
                text: qsTr("Select from one of the previous games:")
            }
            SpinBox {
                id: gameSelector
                from: 1
                to: Wurdl.todaysWordIndex()
                wrap: true
            }
            Label {
                Layout.fillWidth: true
                font.pixelSize: Qt.application.font.pixelSize * 0.85
                opacity: 0.7
                text: qsTr("(counting started on 2021-02-02)")
            }
        }
        onAccepted: game.newGame(gameSelector.value-1)
    }

    // TODO make a first run / help dialog

    QtObject {
        id: game
        property int currentGameIndex: Wurdl.todaysWordIndex()
        onCurrentGameIndexChanged: {
            console.debug("!!! New current game index:", currentGameIndex)
        }
        readonly property string currentGameWord: Wurdl.getWord(currentGameIndex)
        onCurrentGameWordChanged: {
            console.debug("!!! New game word:", currentGameWord)
            console.debug("!!! Is the word in dictionary?", Wurdl.checkWord(currentGameWord))
        }

        property int currentRow: 0
        onCurrentRowChanged: {
            console.debug("Current row changed:", currentRow)
            Qt.callLater(recalcMatchingLetters);
        }

        property int currentIndex: 0
        onCurrentIndexChanged: {
            console.debug("Current index:", currentIndex);
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
                //console.debug("!!! CHECKING CELL FOR MATCHES:", i);
                if (cell.hasExactMatch && !exactMatches.includes(cell.letter)) {
                    //console.debug("!!! EXACT:", cell.letter);
                    exactMatches.push(cell.letter);
                } else if (cell.hasPartialMatch && !partialMatches.includes(cell.letter)) {
                    //console.debug("!!! PARTIAL:", cell.letter);
                    partialMatches.push(cell.letter);
                } else if (!otherLetters.includes(cell.letter)) {
                    otherLetters.push(cell.letter);
                }
            }
            console.debug("Exact matching kbd letters:", exactMatches);
            console.debug("Partially matching kbd letters:", partialMatches);
            console.debug("Other used kbd letters:", otherLetters);
            exactMatchingLetters = exactMatches;
            partiallyMatchingLetters = partialMatches;
            usedLetters = otherLetters;
        }

        function newGame(newIndex) {
            for (let i = 0; i < currentIndex; i++) {
                const cell = gameGridRepeater.itemAt(i);
                cell.letter = "";
                cell.hasExactMatch = false;
                cell.hasPartialMatch = false;
            }
            currentIndex = 0;
            currentRow = 0;
            gameWon = false;
            gameLost = false;
            exactMatchingLetters = [];
            partiallyMatchingLetters = [];
            usedLetters.length = [];
            currentGameIndex = newIndex ?? Wurdl.randomWordIndex()
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
            for (var i = 0; i < Wurdl.totalColumns; i++) {
                const cell = gameGridRepeater.itemAt(currentRow * Wurdl.totalColumns + i);
                result.push(cell.letter);
            }
            return result.join('');
        }

        function highlightCurrentRow() {
            var secondPass = [...currentGameWord]
            // first search for exact matches
            for (var i = 0; i < Wurdl.totalColumns; i++) {
                const cell = gameGridRepeater.itemAt(currentRow * Wurdl.totalColumns + i);
                if (cell.letter === currentGameWord[i]) {
                    cell.hasExactMatch = true;
                    secondPass[i] = " ";
                }
            }
            // do a second pass searching for partial matches
            for (var j = 0; j < Wurdl.totalColumns; j++) {
                const cell = gameGridRepeater.itemAt(currentRow * Wurdl.totalColumns + j);
                if (!cell.hasExactMatch && secondPass.includes(cell.letter)) {
                    cell.hasPartialMatch = true;
                    const idx = secondPass.indexOf(cell.letter);
                    if (idx !== -1) {
                        secondPass.splice(idx, 1, " ");
                    }
                }
            }
        }

        function checkPressed() {
            console.debug("!!! OK pressed")
            const cw = currentRowWord();
            console.debug("!!! Gathering current row number:", currentRow, "; current row's word:", cw)

            const wordOk = Wurdl.checkWord(cw);
            console.debug("!!! Current word in dictionary:", wordOk);
            if (wordOk) {
                highlightCurrentRow();
                currentRow++;
                if (cw === game.currentGameWord) { // game won
                    gameWon = true;
                    dlg.title = qsTr("Game Won!");
                    dlg.text = qsTr("Congratulations<br><br>" +
                                    "You won the game in %n turn(s)", "", currentRow);
                    dlg.open();
                } else if (currentRow >= Wurdl.totalRows) { // game lost
                    gameLost = true;
                    dlg.title = qsTr("Game Lost :(");
                    dlg.text = qsTr("Unfortunately you couldn't make it this time<br>" +
                                    "The word was: '%1'").arg(game.currentGameWord);
                    dlg.open();
                }
            } else {
                dlg.title = qsTr("Word Not Found");
                dlg.text = qsTr("The word '%1' was not found in dictionary, try again.").arg(cw);
                dlg.open();
            }
        }

        function deletePressed() {
            console.debug("!!! Delete pressed")
            removeLastLetter();
        }

        function keyPressed(letter) {
            //console.debug("!!! Letter pressed", letter);
            putLetter(currentIndex, letter);
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 24
        anchors.margins: 4

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
            specialButtons: true
            model: ["z", "x", "c", "v", "b", "n", "m"]
            onLetterPressed: game.keyPressed(letter)
            onCheckPressed: game.checkPressed()
            onDeletePressed: game.deletePressed()
        }
    }
}
