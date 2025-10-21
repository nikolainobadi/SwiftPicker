//
//  PickerInput.swift
//
//
//  Created by Nikolai Nobadi on 5/16/24.
//

/// A protocol defining the input methods required for SwiftPicker.
/// Provides methods for cursor control, screen manipulation, and reading user input.
internal protocol PickerInput {
    /// Turns off the cursor.
    func cursorOff()
    
    /// Moves the cursor to the right.
    func moveRight()
    
    /// Moves the cursor to the home position.
    func moveToHome()
    
    /// Clears the input buffer.
    func clearBuffer()
    
    /// Clears the screen.
    func clearScreen()
    
    /// Restores the cursor and terminal to normal input mode.
    func enableNormalInput()
    
    /// Checks if a key has been pressed.
    /// - Returns: `true` if a key has been pressed, `false` otherwise.
    func keyPressed() -> Bool
    
    /// Writes text to the terminal.
    /// - Parameter text: The text to write.
    func write(_ text: String)
    
    /// Exits the alternative screen mode.
    func exitAlternativeScreen()
    
    /// Enters the alternative screen mode.
    func enterAlternativeScreen()
    
    /// Moves the cursor to the specified row and column.
    /// - Parameters:
    ///   - row: The row to move the cursor to.
    ///   - col: The column to move the cursor to.
    func moveTo(_ row: Int, _ col: Int)
    
    /// Reads a direction key input (e.g., up, down).
    /// - Returns: A Direction value indicating the key pressed, or `nil` if no direction key was pressed.
    func readDirectionKey() -> Direction?
    
    /// Reads a special character input (e.g., enter, space, quit).
    /// - Returns: A SpecialChar value indicating the key pressed, or `nil` if no special character was pressed.
    func readSpecialChar() -> SpecialChar?
    
    /// Reads the current cursor position.
    /// - Returns: A tuple containing the row and column of the cursor position.
    func readCursorPos() -> (row: Int, col: Int)
    
    /// Reads the current screen size.
    /// - Returns: A tuple containing the number of rows and columns of the screen size.
    func readScreenSize() -> (rows: Int, cols: Int)
}

// MARK: - Dependencies

/// An enumeration representing direction keys (up, down).
internal enum Direction {
    case up, down
}

/// An enumeration representing special characters (enter, space, quit).
internal enum SpecialChar {
    case enter, space, quit
}
