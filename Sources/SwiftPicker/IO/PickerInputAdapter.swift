//
//  PickerInputAdapter .swift
//
//
//  Created by Nikolai Nobadi on 5/16/24.
//

import ANSITerminal

/// A class that adapts the PickerInput protocol to use ANSITerminal for input handling.
/// Provides methods for cursor control, screen manipulation, and reading user input.
final class PickerInputAdapter: PickerInput {
    /// Turns off the cursor.
    func cursorOff() {
        ANSITerminal.cursorOff()
    }
    
    /// Moves the cursor to the right.
    func moveRight() {
        ANSITerminal.moveRight()
    }
    
    /// Moves the cursor to the home position.
    func moveToHome() {
        ANSITerminal.moveToHome()
    }
    
    /// Clears the input buffer.
    func clearBuffer() {
        ANSITerminal.clearBuffer()
    }
    
    /// Clears the screen.
    func clearScreen() {
        ANSITerminal.clearScreen()
    }
    
    /// Restores the cursor and terminal to normal input mode.
    func enableNormalInput() {
        ANSITerminal.cursorOn()
        ANSITerminal.restoreDefaultTerminal()
    }
    
    /// Checks if a key has been pressed.
    /// - Returns: `true` if a key has been pressed, `false` otherwise.
    func keyPressed() -> Bool {
        return ANSITerminal.keyPressed()
    }
    
    /// Writes text to the terminal.
    /// - Parameter text: The text to write.
    func write(_ text: String) {
        ANSITerminal.write(text)
    }
    
    /// Exits the alternative screen mode.
    func exitAlternativeScreen() {
        ANSITerminal.exitAlternativeScreen()
    }
    
    /// Enters the alternative screen mode.
    func enterAlternativeScreen() {
        ANSITerminal.enterAlternativeScreen()
    }
    
    /// Moves the cursor to the specified row and column.
    /// - Parameters:
    ///   - row: The row to move the cursor to.
    ///   - col: The column to move the cursor to.
    func moveTo(_ row: Int, _ col: Int) {
        ANSITerminal.moveTo(row, col)
    }
    
    /// Reads a direction key input (e.g., up, down).
    /// - Returns: A Direction value indicating the key pressed, or `nil` if no direction key was pressed.
    func readDirectionKey() -> Direction? {
        switch ANSITerminal.readKey().code {
        case .up: return .up
        case .down: return .down
        default: return nil
        }
    }
    
    /// Reads a special character input (e.g., enter, space, quit).
    /// - Returns: A SpecialChar value indicating the key pressed, or `nil` if no special character was pressed.
    func readSpecialChar() -> SpecialChar? {
        let char = ANSITerminal.readChar()
        if char == NonPrintableChar.enter.char() { return .enter }
        if char == " " { return .space }
        if char == "q" || char == "Q" { return .quit }
        return nil
    }
    
    /// Reads the current cursor position.
    /// - Returns: A tuple containing the row and column of the cursor position.
    func readCursorPos() -> (row: Int, col: Int) {
        return ANSITerminal.readCursorPos()
    }
    
    /// Reads the current screen size.
    /// - Returns: A tuple containing the number of rows and columns of the screen size.
    func readScreenSize() -> (rows: Int, cols: Int) {
        return ANSITerminal.readScreenSize()
    }
}
