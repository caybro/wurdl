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

    Component.onCompleted: {
        if (settings.firstRun) {
            helpDialog.open();
        }
    }

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
                        icon.source: "qrc:/icons/outline_help_outline_black_24dp.png"
                        text: qsTr("How to Play")
                        onClicked: helpDialog.open()
                    }
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
                icon.source: "qrc:/icons/outline_leaderboard_black_24dp.png"
                ToolTip.text: qsTr("Scores")
                ToolTip.visible: hovered
                onClicked: statsDlg.open()
            }
        }
    }

    Settings {
        id: settings
        property alias x: root.x
        property alias y: root.y
        property alias width: root.width
        property alias height: root.height
        property alias lastHistoryGame: gameSelector.value
        property bool firstRun: true
    }

    GameDialog {
        id: dlg
        property alias text: dlgLabel.text
        Label {
            id: dlgLabel
            width: parent.width
            anchors.centerIn: parent
            wrapMode: Label.Wrap
        }
    }

    GameDialog {
        id: statsDlg
        title: qsTr("Score Statistics")

        property var stats: Wurdl.getScoreStats()

        ColumnLayout {
            Label {
                text: qsTr("Games played: %1").arg(statsDlg.stats["total"])
            }
            Label {
                text: qsTr("Won: %L1%").arg(statsDlg.stats["won_percent"])
            }
            Label {
                text: qsTr("Total score: %1").arg(statsDlg.stats["total_score"])
            }
            Label {
                text: "<br><b>6 pts.</b>: %1<br>".arg(statsDlg.stats["6"]) +
                      "<b>5 pts.</b>: %1<br>".arg(statsDlg.stats["5"]) +
                      "<b>4 pts.</b>: %1<br>".arg(statsDlg.stats["4"]) +
                      "<b>3 pts.</b>: %1<br>".arg(statsDlg.stats["3"]) +
                      "<b>2 pts.</b>: %1<br>".arg(statsDlg.stats["2"]) +
                      "<b>1 pt.</b>: %1<br>".arg(statsDlg.stats["1"]) +
                      "<b>0 pts.</b>: %1<br>".arg(statsDlg.stats["0"])
            }
        }
        onAboutToShow: stats = Wurdl.getScoreStats()
    }

    GameDialog {
        id: prevGameDlg
        standardButtons: Dialog.Ok | Dialog.Cancel
        title: qsTr("Play Previous Game")
        ColumnLayout {
            anchors.fill: parent
            Label {
                Layout.fillWidth: true
                text: qsTr("Select from one of the previous games:")
            }
            RowLayout {
                SpinBox {
                    id: gameSelector
                    from: 0
                    to: Wurdl.todaysWordIndex()-1
                    wrap: true
                    value: Wurdl.todaysWordIndex()-1 // start with yesterday's word by default
                    textFromValue: function(value) { return Number(value)+1; }
                    // enable only games that haven't been played before
                    onValueChanged: prevGameDlg.standardButton(Dialog.Ok).enabled = Wurdl.getScore(value) === -1;
                }
                Label {
                    text: qsTr("Score: %1").arg(Wurdl.getScore(gameSelector.value))
                }
            }
            Label {
                Layout.fillWidth: true
                font.pixelSize: Qt.application.font.pixelSize * 0.85
                opacity: 0.7
                text: qsTr("(counting started on 2021-02-02)")
            }
        }
        onAccepted: game.newGame(gameSelector.value)
    }

    GameDialog {
        id: helpDialog
        title: qsTr("How to Play")
        ColumnLayout {
            anchors.fill: parent
            Label {
                Layout.fillWidth: true
                wrapMode: Label.Wrap
                text: qsTr("Guess the word in 6 tries. After each try, the letter gets colored according to " +
                           "how far your guess was from the original word.")
            }
            Row {
                Layout.topMargin: 12
                spacing: 6
                Cell {
                    letter: "k"
                    border.color: Material.foreground
                    hasExactMatch: true
                }
                Cell { letter: "o"; color: "transparent" }
                Cell { letter: "č"; color: "transparent" }
                Cell { letter: "k"; color: "transparent" }
                Cell { letter: "a"; color: "transparent" }
            }
            Label {
                Layout.fillWidth: true
                wrapMode: Label.Wrap
                text: qsTr("Letter <b>K</b> is contained in the word and placed <b>correctly</b>.")
            }
            Row {
                Layout.topMargin: 12
                spacing: 6
                Cell {
                    letter: "p"
                    border.color: Material.foreground
                    color: "transparent"
                }
                Cell { letter: "i"; color: "transparent" }
                Cell {
                    letter: "l"
                    hasPartialMatch: true
                }
                Cell { letter: "o"; color: "transparent" }
                Cell { letter: "t"; color: "transparent" }
            }
            Label {
                Layout.fillWidth: true
                wrapMode: Label.Wrap
                text: qsTr("Letter <b>L</b> is contained in the word but <b>misplaced</b>.")
            }
            Row {
                Layout.topMargin: 12
                spacing: 6
                Cell {
                    letter: "m"
                    border.color: Material.foreground
                    color: "transparent"
                }
                Cell { letter: "e"; color: "transparent" }
                Cell { letter: "t"; color: "transparent" }
                Cell {
                    letter: "r"
                    color: game.noMatchColor
                }
                Cell { letter: "o"; color: "transparent" }
            }
            Label {
                Layout.fillWidth: true
                wrapMode: Label.Wrap
                text: qsTr("Letter <b>R</b> is <b>not contained</b> in the word being searched.")
            }
        }
        onClosed: settings.firstRun = false;
    }

    QtObject {
        id: game
        readonly property color exactMatchColor: Material.color(Material.Green)
        readonly property color partialMatchColor: Material.color(Material.Orange)
        readonly property color noMatchColor: Material.color(Material.Grey)

        property int currentGameIndex: debugMode ? Wurdl.randomWordIndex() : Wurdl.todaysWordIndex()
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

        readonly property int currentScore: gameWon ? 7 - currentRow : 0 // 6..1 for wins, 0 for loss, -1 for not played

        property var exactMatchingLetters: []
        property var partiallyMatchingLetters: []
        property var usedLetters: []

        function recalcMatchingLetters() {
            var exactMatches = [];
            var partialMatches = [];
            var otherLetters = [];
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
            currentGameIndex = newIndex ?? Wurdl.randomWordIndex();
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
            var secondPass = [...currentGameWord]; // string -> array of chars
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

        function createTweet() {
            var text = "Wurdl %1 %2/6\n".arg(currentGameIndex+1).arg(currentRow);
            for (let i = 0; i < currentIndex; i++) {
                const cell = gameGridRepeater.itemAt(i);
                if (i % Wurdl.totalColumns === 0)
                    text += "\n";
                if (cell.hasExactMatch)
                    text += "🟩";
                else if (cell.hasPartialMatch)
                    text += "🟧";
                else
                    text += "⬜";
            }
            //console.debug("!!! Tweet:", text);
            return text;
        }

        function checkPressed() {
            console.debug("!!! OK pressed");
            const cw = currentRowWord();
            console.debug("!!! Gathering current row number:", currentRow, "; current row's word:", cw);

            const wordOk = Wurdl.checkWord(cw);
            console.debug("!!! Current word in dictionary:", wordOk);
            if (wordOk) {
                highlightCurrentRow();
                currentRow++;
                if (cw === game.currentGameWord) { // game won
                    gameWon = true;
                    // TODO make "win" dialog with Share button
                    const tweet = createTweet();
                    dlg.title = qsTr("Game Won!");
                    dlg.text = qsTr("Congratulations<br><br>" +
                                    "You won the game in %n turn(s).<br><br>" +
                                    "Your score: %1<br><br>Your stats have been copied to cliboard.", "", currentRow).arg(currentScore);
                    Wurdl.setScore(currentGameIndex, currentScore);
                    Wurdl.shareCurrentGame(tweet);
                    dlg.open();
                } else if (currentRow >= Wurdl.totalRows) { // game lost
                    gameLost = true;
                    dlg.title = qsTr("Game Lost :(");
                    dlg.text = qsTr("Unfortunately you couldn't make it this time.<br>" +
                                    "The word was: '%1'").arg(game.currentGameWord);
                    Wurdl.setScore(currentGameIndex, currentScore);
                    dlg.open();
                }
            } else {
                dlg.title = qsTr("Word Not Found");
                dlg.text = qsTr("The word '%1' was not found in dictionary, try again.").arg(cw);
                dlg.open();
            }
        }

        function deletePressed() {
            console.debug("!!! Delete pressed");
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
        anchors.margins: 6

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

        Label {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Label.AlignHCenter
            font.pixelSize: Qt.application.font.pixelSize * 0.85
            opacity: 0.7
            text: "(c) 2022 caybro; version %1".arg(Qt.application.version)
        }
    }
}
