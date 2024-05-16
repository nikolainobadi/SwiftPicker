//
//  PickerInputAdapter.swift
//
//
//  Created by Nikolai Nobadi on 5/16/24.
//

import ANSITerminal

internal final class PickerInputAdapter: PickerInput {
    func moveRight() {
        ANSITerminal.moveRight()
    }
    
    func moveToHome() {
        ANSITerminal.moveToHome()
    }
    
    func clearScreen() {
        ANSITerminal.clearScreen()
    }
    
    func clearBuffer() {
        ANSITerminal.clearBuffer()
    }
    
    func enableNormalInput() {
        ANSITerminal.cursorOff()
        ANSITerminal.restoreDefaultTerminal()
    }
    
    func keyPressed() -> Bool {
        return ANSITerminal.keyPressed()
    }
    
    func write(_ text: String) {
        ANSITerminal.write(text)
    }
    
    func enterAlternativeScreen() {
        ANSITerminal.enterAlternativeScreen()
    }
    
    func exitAlternativeScreen() {
        ANSITerminal.exitAlternativeScreen()
    }
    
    func moveTo(_ row: Int, _ col: Int) {
        ANSITerminal.moveTo(row, col)
    }
    
    func readDirectionKey() -> Direction? {
        switch ANSITerminal.readKey().code {
        case .up:
            return .up
        case .down:
            return .down
        default:
            return nil
        }
    }
    
    func readSpecialChar() -> SpecialChar? {
        let char = ANSITerminal.readChar()
        
        if char == NonPrintableChar.enter.char() {
            return .enter
        }
        
        if char == " " {
            return .space
        }
        
        return nil
    }
    
    func readCursorPos() -> (row: Int, col: Int) {
        return ANSITerminal.readCursorPos()
    }
    
    func readScreenSize() -> (rows: Int, cols: Int) {
        return ANSITerminal.readScreenSize()
    }
}
