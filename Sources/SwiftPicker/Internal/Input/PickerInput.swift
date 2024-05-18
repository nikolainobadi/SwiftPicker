//
//  PickerInput.swift
//
//
//  Created by Nikolai Nobadi on 5/16/24.
//

internal protocol PickerInput {
    func cursorOff()
    func moveRight()
    func moveToHome()
    func clearBuffer()
    func clearScreen()
    func enableNormalInput()
    func keyPressed() -> Bool
    func write(_ text: String)
    func exitAlternativeScreen()
    func enterAlternativeScreen()
    func moveTo(_ row: Int, _ col: Int)
    func readDirectionKey() -> Direction?
    func readSpecialChar() -> SpecialChar?
    func readCursorPos() -> (row: Int, col: Int)
    func readScreenSize() -> (rows: Int, cols: Int)
}


// MARK: - Dependencies
internal enum Direction {
    case up, down
}

internal enum SpecialChar {
    case enter, space
}

