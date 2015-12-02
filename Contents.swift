// Final Project : Dot Game
// Cindy Grieb

import Foundation

// enumerations and structures
enum Side {
    case Top
    case Right
    case Bottom
    case Left
    case None
    
    func setSide(s: String) -> Side {
        switch s.uppercaseString {
        case "TOP" : return .Top
        case "RIGHT" : return .Right
        case "BOTTOM" : return .Bottom
        case "LEFT" : return .Left
        default : return .None
        }
    }
}

struct PlayerMove {
    var rowChosen : String {
        didSet {
            rowChosen = rowChosen.uppercaseString
        }
    }
    var columnChosen : String {
        didSet {
            rowChosen = rowChosen.uppercaseString
        }
    }
    var sideChosen : Side
    
    init() {
        self.rowChosen = "A"
        self.columnChosen = "A"
        self.sideChosen = .None
    }
}

class DotGame {
    // **************************** constant attribute values ***************************
    // attribute values used to validate game values
    let maxPlayer : Int = 2       // maximum number of players allowed
    let minSize : Int = 3            // minimum matrix size
    let maxSize : Int = 26           // maximum matrix size (A-Z)
    
    // Unicode value for a fixed width dot (asterisk)
    let dot : String = "\u{FF0A}"
    // Unicode value for a fixed width space to match the other codes
    let space : String = "\u{3000}"  // Unicode ideographic space
    // Unicode values for horizontal bar styles for each player
    let horizBar : [String] =
        ["\u{FF5E}","\u{FF1D}"]
    // Unicode values for vertical bar styles for each player
    let vertBar : [String] =
        ["\u{FF5C}","\u{FF1A}"]
    // Unicode values for fixed width digits 0-9
    let fullWidthDigits : [String] = ["\u{FF10}","\u{FF11}","\u{FF12}","\u{FF13}","\u{FF14}","\u{FF15}","\u{FF16}",
        "\u{FF17}","\u{FF18}","\u{FF19}"]
    // Unicode values for fixed width letters A-Z
    let fullWidthLetters : [String] = ["\u{FF21}", "\u{FF22}", "\u{FF23}", "\u{FF24}", "\u{FF25}", "\u{FF26}", "\u{FF27}", "\u{FF28}", "\u{FF29}", "\u{FF2A}", "\u{FF2B}", "\u{FF2C}", "\u{FF2D}", "\u{FF2E}", "\u{FF2F}", "\u{FF30}", "\u{FF31}", "\u{FF32}", "\u{FF33}", "\u{FF34}", "\u{FF35}", "\u{FF36}", "\u{FF37}", "\u{FF38}", "\u{FF39}", "\u{FF3A}"]
    // the scalar value of the letter A will be used to relate a letter to
    // its corresponding Unicode full width letter in the above array
    let offset = Int(UnicodeScalar("A").value)        // offset for index into array
    
    // ************** variable attribute values  *************
    // attributes values for the current game
    var newGame : Bool            // true when starting a new game
    var matrixSize : Int          // size of the game matrix (square)
    var currentPlayer : Int       // indicates whose turn it is
    var lastTurn : Int            // flag to track when player has entered their data
    var statusMessage : String    // status report
    
    // used to determine whether the player has entered their move
    var lastMove : PlayerMove       // the previous values
    
    // attributes to store current state of the game board
    var horizontal : [[Int]]       // current state of the board for horizontal moves
    var vertical : [[Int]]         // current state of the board for vertical moves
    var squares : [[Int]]          // player numbers for claimed squares
    
    // ********************* init() *********************
    // initializer to set up a new game instance
    init() {
        self.newGame = true
        self.matrixSize = 3
        self.currentPlayer = 1  // player 1 has the first turn
        self.lastTurn = 0       // when this value changes, grab player data
        self.statusMessage = "Your move player 1"
        self.lastMove = PlayerMove()
        
        // horizontal has n+1 rows of n columns
        self.horizontal = Array(count: (matrixSize+1), repeatedValue: Array(count: (matrixSize), repeatedValue: 0))
        // vertical has n rows of n+1 columns
        self.vertical = Array(count: (matrixSize), repeatedValue: Array(count: (matrixSize+1), repeatedValue: 0))
        // squares has n rows of n columns
        self.squares = Array(count: matrixSize, repeatedValue: Array(count: matrixSize, repeatedValue: 0))
    }
    
    // ********************************** displayBoard() *********************************************
    // method to display the board in its current state
    // ***********************************************************************************************
    func displayBoard() {
        // the header row(s) at the top label the grid for the players
        func displayHeaderRow() {
            // loop through the columns and label them
            print("\(space)\(space)\(space)", terminator: "")
            for var col = 0; col < matrixSize; col++ {
                print("\(space)\(fullWidthLetters[col])\(space)\(space)", terminator: "")
            }
            print("\n", terminator: "")
        }
        // horizontal rows have dots in them and dots may be connected horizontally
        func displayHorizontalRow(row: Int) {
            print("\(space)\(space)", terminator: "")
            for var col = 0; col < matrixSize; col++ {
                print("\(dot)", terminator: "")
                if horizontal[row][col] > 0 {
                    let c = horizBar[horizontal[row][col]-1]
                    print("\(c)\(c)\(c)", terminator: "")
                } else {
                    print("\(space)\(space)\(space)", terminator: "")
                }
            }
            print("\(dot)", terminator: "")             // the last column of dots
            print("\n", terminator: "")                         // and finish the line
        }
        // vertical rows may be connected vertically to dots above or below
        func displayVerticalRow(row: Int) {
            // label this row
            print("\(fullWidthLetters[row])\(space)", terminator: "")
            // then display the row
            for var col = 0; col < matrixSize; col++ {
                if vertical[row][col] > 0 {
                    print("\(vertBar[vertical[row][col]-1])", terminator: "")
                } else {
                    print("\(space)", terminator: "")
                }
                if squares[row][col] > 0 {
                    print("\(space)\(fullWidthDigits[squares[row][col]])\(space)", terminator: "")
                } else {
                    print("\(space)\(space)\(space)", terminator: "")
                }
            }
            if vertical[row][matrixSize] > 0 {
                print("\(vertBar[vertical[row][matrixSize]-1])", terminator: "")
            }
            print("\n", terminator: "")
        }
        
        // main body of displayBoard()
        displayHeaderRow()
        for var row = 0; row < self.matrixSize; row++ {
            // display a horizontal row
            displayHorizontalRow(row)
            // display a vertical row
            displayVerticalRow(row)
        }
        displayHorizontalRow(matrixSize)
    } /* end func displayBoard() */
    
    // ************************************ gameOver() ***********************************************
    // method to determine if anyone won the game
    // ***********************************************************************************************
    func gameOver() -> Bool {
        var totalCount : Int = 0
        for var row = 0; row < self.matrixSize; row++ {
            for var col = 0; col < self.matrixSize; col++ {
                if squares[row][col] > 0 {
                    totalCount++
                }
            }
        }
        return totalCount == matrixSize * matrixSize
    }

    // ********************************** declareWinner() ********************************************
    // determine who the winner is and display the status -- note: only come here if game is over
    // ***********************************************************************************************
    func declareWinner() {
        var winner : [Int] = Array(count: self.maxPlayer, repeatedValue: 0)
        var winningPlayer : Int = -1
        for var row = 0; row < self.matrixSize; row++ {
            for var col = 0; col < self.matrixSize; col++ {
                if squares[row][col] > 0 {
                    winner[squares[row][col] - 1]++
                }
            }
        }
        let sortedArray = winner.sort({$0 > $1})
        if sortedArray[0] > sortedArray[1] {
            var player = 0
            repeat {
                if winner[player] == sortedArray[0] {
                    winningPlayer = player
                }
            } while winningPlayer == -1 && ++player < self.maxPlayer
            self.statusMessage = "Congratulations! You won player \(winningPlayer+1)"
        } else if sortedArray[0] == sortedArray[1] {
            self.statusMessage = "The game is a tie!"
        }
        self.displayStatus()
    }
    
    // ********************************** resetGame() ************************************************
    // reset all values to original value
    // ***********************************************************************************************
    func resetGame() {
        self.newGame = true
        self.matrixSize = 2
        self.currentPlayer = 1  // player 1 has the first turn
        self.lastTurn = 0       // when this value changes, grab player data
        self.statusMessage = "Your move player 1"
        self.lastMove = PlayerMove()
        
        // horizontal has n+1 rows of n columns
        self.horizontal = Array(count: (matrixSize+1), repeatedValue: Array(count: (matrixSize), repeatedValue: 0))
        // vertical has n rows of n+1 columns
        self.vertical = Array(count: (matrixSize), repeatedValue: Array(count: (matrixSize+1), repeatedValue: 0))
        // squares has n rows of n columns
        self.squares = Array(count: matrixSize, repeatedValue: Array(count: matrixSize, repeatedValue: 0))
    }
    
    // ********************************** checkForSquare() *******************************************
    // check to see if any squares have been claimed
    // ***********************************************************************************************
    func squareClaimed(move: PlayerMove) -> Bool {
        var claimed : Bool = false
        let r = Int(move.rowChosen.unicodeScalars[move.rowChosen.unicodeScalars.startIndex].value) - self.offset
        let c = Int(move.columnChosen.unicodeScalars[move.columnChosen.unicodeScalars.startIndex].value) - self.offset
        switch move.sideChosen {
        case .Top:
            if vertical[r][c] > 0 && vertical[r][c+1] > 0 && horizontal[r+1][c] > 0 {
                squares[r][c] = self.currentPlayer
                claimed = true
            }
            if r > 0 {
                if vertical[r-1][c] > 0 && vertical[r-1][c+1] > 0 && horizontal[r-1][c] > 0 {
                    squares[r-1][c] = self.currentPlayer
                    claimed = true
                }
            }
        case .Right:
            if vertical[r][c] > 0 && horizontal[r][c] > 0 && horizontal[r+1][c] > 0 {
                squares[r][c] = self.currentPlayer
                claimed = true
            }
            if c < self.matrixSize-1 {
                if vertical[r][c+2] > 0 && horizontal[r][c+1] > 0 && horizontal[r+1][c+1] > 0 {
                    squares[r][c+1] = self.currentPlayer
                    claimed = true
                }
            }
        case .Bottom:
            if vertical[r][c] > 0 && vertical[r][c+1] > 0 && horizontal[r][c] > 0 {
                squares[r][c] = self.currentPlayer
                claimed = true
            }
            if r < self.matrixSize - 1 {
                if vertical[r+1][c] > 0 && vertical[r+1][c+1] > 0 && horizontal[r+2][c] > 0 {
                    squares[r+1][c] = self.currentPlayer
                    claimed = true
                }
            }
        case .Left:
            if vertical[r][c+1] > 0 && horizontal[r][c] > 0 && horizontal[r+1][c] > 0 {
                squares[r][c] = self.currentPlayer
                claimed = true
            }
            if c > 0 {
                if vertical[r][c-1] > 0 && horizontal[r][c-1] > 0 && horizontal[r+1][c-1] > 0 {
                    squares[r][c-1] = self.currentPlayer
                    claimed = true
                }
            }
        case .None:
            break
        }
        return claimed
    }
    
    // ********************************** nextPlayer() ***********************************************
    // return the next player, based on the current player
    // ***********************************************************************************************
    func nextPlayer() -> Int {
        return self.currentPlayer + 1 > self.maxPlayer ? 1 : currentPlayer + 1
    }
    
    // ********************************** validPlayer()***********************************************
    // method to determine if the player number entered is valid
    // ***********************************************************************************************
    func validPlayer(p: Int) -> Bool {
        return p >= 0 && p < self.maxPlayer && p != self.currentPlayer
    }
    
    // ********************************** displayStatus() ********************************************
    // display the current status message
    // ***********************************************************************************************
    func displayStatus() -> () {
        if !self.statusMessage.isEmpty {
            print("\(self.statusMessage)\n")
            self.statusMessage = ""
        }
    }
    
    // ********************************** dataUpdated() **********************************************
    // function to test for change in data. data has been updated if move != last
    // ***********************************************************************************************
    func dataUpdated(turn: Int) -> Bool {
        return turn != self.lastTurn
    }

    // *********************************** validMove() ***********************************************
    // method to determine if the proposed move is valid and set the array value if valid
    // ***********************************************************************************************
    func validMove(move : PlayerMove) -> Bool {
        // test for validity of horizontal move
        func horizontalMove(r: Int, c: Int) -> Bool {
            if (r >= 0) && (r < self.matrixSize+1) && (c >= 0) && (c < self.matrixSize) {
                if (horizontal[r][c] == 0) {
                    self.horizontal[r][c] = self.currentPlayer
                    return true
                } else {
                    self.statusMessage = "That position is already occupied. Please try again."
                    return false
                }
            } else {
                self.statusMessage = "Invalid Move. Please try again."
                return false
            }
        }
        // test for validity of vertical move
        func verticalMove(r: Int, c: Int) -> Bool {
            if (r >= 0) && (r < self.matrixSize) && (c >= 0) && (c < self.matrixSize+1) {
                if (vertical[r][c] == 0) {
                    self.vertical[r][c] = self.currentPlayer
                    return true
                } else {
                    self.statusMessage = "That position is already occupied. Please try again."
                    return false
                }
            } else {
                self.statusMessage = "Invalid Move. Please try again."
                return false
            }
        }

        if move.rowChosen.isEmpty || move.columnChosen.isEmpty {
            return false
        } else {
            let r = Int(move.rowChosen.unicodeScalars[move.rowChosen.unicodeScalars.startIndex].value) - self.offset
            let c = Int(move.columnChosen.unicodeScalars[move.columnChosen.unicodeScalars.startIndex].value) - self.offset
            switch move.sideChosen {
            case .Top :
                return horizontalMove(r, c: c)
            case .Bottom :
                return horizontalMove(r+1, c: c)
            case .Right :
                return verticalMove(r, c: c+1)
            case .Left :
                return verticalMove(r, c: c)
            case .None :
                return false
            }
        }
    } /* end func validMove() */

    // *********************************** writeData() ***********************************************
    // function to write instance data into the data file (will overwrite)
    // ***********************************************************************************************
    func writeData() {
        // generates a comma-delimited string of data containing variable data for this instance
        func stringData() -> String {
            var s : String = "\(self.newGame),\(self.matrixSize),\(self.currentPlayer)," +
                "\(statusMessage),\(self.lastMove.columnChosen)," +
                "\(self.lastMove.rowChosen),\(self.lastMove.sideChosen),\(self.lastTurn),"
            for subarray in self.horizontal {
                for i in subarray {
                    s += "\(i),"
                }
            }
            for subarray in self.vertical {
                for i in subarray {
                    s += "\(i),"
                }
            }
            for subarray in self.squares {
                for i in subarray {
                    s += "\(i),"
                }
            }
            //s.removeAtIndex(s.endIndex.predecessor()) - need to leave the final comma in place
            return s
        }
        
        // main body of writeData()
        if let filePath = NSBundle.mainBundle().pathForResource("DotGame", ofType: "txt") {
            let data = stringData()
            do {
                try data.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding)
            } catch _ { print("Write failed") }
        }
    }
    
    // ************************************ readData() ***********************************************
    // function to load the data file (if it exists) into the instance variables
    // ***********************************************************************************************
    func readData() {
        // pull data back out of the saved string and load them into the instance variables
        func tokenizeData(fileData: String) {
            // remove first token from the original string and return string found with the edited original
            func getToken(var data: String, ndx: String.Index) -> (String, String) {
                // return the position of the first occurrence of comma in string or data.endIndex if not found
                func nextComma(data: String) -> String.Index {
                    var ndx = data.startIndex
                    if !data.isEmpty {
                        repeat {
                            if data[ndx] == "," {
                                return ndx
                            }
                        } while ++ndx < data.endIndex
                    }
                    return data.endIndex
                }
                
                // main body of getToken()
                var s : String = String()
                let lastIndex = nextComma(data)
                if lastIndex < data.endIndex {
                    for var i = ndx; i < lastIndex; i++ {
                        s.append(data[i])
                    }
                    data.removeRange(s.startIndex...lastIndex)
                }
                return (s, data)
            }
            
            // main body of tokenizeData()
            var data = fileData
            var str : String = String()
            (str, data) = getToken(data, ndx: data.startIndex)
            if str == "true" {
                self.newGame = true
            } else {
                self.newGame = false
            }
            (str, data) = getToken(data, ndx: data.startIndex)
            self.matrixSize = Int(str)!
            (str, data) = getToken(data, ndx: data.startIndex)
            self.currentPlayer = Int(str)!
            (str, data) = getToken(data, ndx: data.startIndex)
            statusMessage = str
            (str, data) = getToken(data, ndx: data.startIndex)
            self.lastMove.columnChosen = str
            (str, data) = getToken(data, ndx: data.startIndex)
            self.lastMove.rowChosen = str
            (str, data) = getToken(data, ndx: data.startIndex)
            self.lastMove.sideChosen.setSide(str)
            (str, data) = getToken(data, ndx: data.startIndex)
            self.lastTurn = Int(str)!
            
            for var row = 0; row < self.matrixSize+1; row++ {
                for var col = 0; col < self.matrixSize; col++ {
                    (str, data) = getToken(data, ndx: data.startIndex)
                    self.horizontal[row][col] = Int(str)!
                }
            }
            for var row = 0; row < self.matrixSize; row++ {
                for var col = 0; col < self.matrixSize+1; col++ {
                    (str, data) = getToken(data, ndx: data.startIndex)
                    self.vertical[row][col] = Int(str)!
                }
            }
            for var row = 0; row < self.matrixSize; row++ {
                for var col = 0; col < self.matrixSize; col++ {
                    (str, data) = getToken(data, ndx: data.startIndex)
                    self.squares[row][col] = Int(str)!
                }
            }
            
        }
        
        // main body of readData()
        if let filePath = NSBundle.mainBundle().pathForResource("DotGame", ofType: "txt") {
            if let data = String(data: NSData(contentsOfFile: filePath)!, encoding: NSUTF8StringEncoding) {
                if !data.isEmpty {
                    tokenizeData(data)
                }
            }
        }
    }
    
    // ************************************ playGame() ***********************************************
    // function that controls the game play sequence
    // This function uses the re-evaluation feature of the playground as the main loop for the game.
    // In other words, every time the user types in data, the playground refreshes and runs the code
    // from the beginning. So each time it runs it re-loads data from a file and saves it back to file.
    // ***********************************************************************************************
    func playGame(move : PlayerMove, turn : Int) {
        self.readData()
        print("Player 1: \(horizBar[0])\(vertBar[0])  Player 2: \(horizBar[1])\(vertBar[1])\n")
        // check for a change in the player number
        // when player number changes, user has entered their move
        // player number is stored as an array index starting with 0, but entered starting with 1
        if dataUpdated(turn) { //print("%%Data Updated.")
            if self.validMove(move) { //print("%%Valid Move.")
                self.newGame = false
                self.lastMove = move
                if squareClaimed(move) {
                    self.statusMessage = "Your move again, player \(self.currentPlayer)."
                } else {
                    self.currentPlayer = self.nextPlayer()
                    self.statusMessage = "Your move player \(self.currentPlayer)."
                }
                self.displayBoard()
                self.displayStatus()
                // test for end of game. if game is over, need to declare winner and reset game
                if gameOver() { //print("%%Game Over")
                    self.declareWinner()
                    self.resetGame()
                    self.displayBoard()
                    self.displayStatus()
                }
            } else { //print("%%Move: \(move) Player: \(self.currentPlayer)")
                self.displayBoard()
                self.statusMessage = "Invalid move. Please try again player \(self.currentPlayer)."
                self.displayStatus()
            }
            self.lastTurn = turn
        } else { //print("%%Data not updated.")
            self.displayBoard()
            self.statusMessage = "Your move player \(self.currentPlayer)."
            self.displayStatus()
        }
        self.writeData()
    } /* end func playGame() */
   
} /* end class DotGame */

/* main program begins here */

var game : DotGame = DotGame()
var move : PlayerMove = PlayerMove()
var turn : Int

//********************************************************************/
// Enter your move below:                                             /
//    1. Enter values for the row and column first                    /
//    2. Enter values for correct side of the box                     /
//    3. Once row, column and side are set, change the turn number    /
//********************************************************************/

// ENTER row and column FIRST (inside the quote marks)
move.rowChosen = "A"      // Enter the corresponding letter inside the quotes
move.columnChosen = "A"   // Enter the corresponding letter inside the quotes

// ENTER the correct side of the box selected by rowChosen and columnChosen
// Valid values are: .Top, .Right, .Bottom and .Left
move.sideChosen = .Right

// AFTER row and column are entered, change the turn number to any other integer
turn = 0

//**************************************************************/
// Enter your move above!                                       /
//**************************************************************/

game.playGame(move, turn: turn)

