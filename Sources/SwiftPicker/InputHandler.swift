//
//  InputHandler.swift
//
//
//  Created by Nikolai Nobadi on 5/14/24.
//

import Foundation
import ANSITerminal

internal final class InputHandler {
    func setupSelectionState(title: String, options: [String]) -> SelectionState {
        setupTitle(title: title)
        
        let topLine = readCursorPos().row + 1
        let options = makeOptions(list: options, topLine: topLine)
        
        renderOptions(options: options, firstLine: topLine)
        moveLineDown()
        write("└".foreColor(81))
        
        let bottomLine = readCursorPos().row
        
        return SelectionState(options: options, topLine: topLine, bottomLine: bottomLine)
    }
    
    func renderOptions(options: [Option], firstLine: Int) {
        options.forEach { option in
            renderOption(option: option, isActive: option.line == firstLine, row: option.line, col: 0)
        }
    }
    
    func captureUserInput(state: SelectionState) {
        while true {
            clearBuffer()
            if keyPressed() {
                let char = readChar()
                if char == NonPrintableChar.enter.char() {
                    toggleSelection(state: state)
                    break
                }
                handleArrowKeys(state: state)
            }
        }
    }
    
    func captureMultipleUserInput(state: SelectionState) {
        while true {
            clearBuffer()
            if keyPressed() {
                let char = readChar()
                if char == NonPrintableChar.enter.char() {
                    break
                }
                if char == " " {
                    toggleSelection(state: state)
                }
                
                handleArrowKeys(state: state)
            }
        }
    }
    
    func finalizeUI(for state: SelectionState) {
        let startLine = state.topLine - 1
        writeAt(startLine, 0, "✔".green)
        (startLine + 1...state.bottomLine).forEach {
            writeAt($0, 0, "│".foreColor(252))
        }
        
        moveTo(state.bottomLine, 0)
    }
}


// MARK: - Private Methods
private extension InputHandler {
    func setupTitle(title: String) {
        cursorOff()
        moveLineDown()
        write("◆".foreColor(81).bold)
        moveRight()
        write(title)
    }
    
    func makeOptions(list: [String], topLine: Int) -> [Option] {
        return list.enumerated().map { Option(title: $1, line: topLine + $0) }
    }
    
    func renderOption(option: Option, isActive: Bool, row: Int, col: Int) {
        moveTo(row, col)
        write("│".foreColor(81))
        moveRight()
        write(option.isSelected ? "●".lightGreen : "○".foreColor(250))
        moveRight()
        write(isActive ? option.title.underline : option.title.foreColor(250))
    }
    
    func toggleSelection(state: SelectionState) {
        let activeLine = state.activeLine
        state.toggleSelection(at: activeLine)
        reRender(state: state, previousActiveLine: activeLine)
    }
    
    func handleArrowKeys(state: SelectionState) {
        let key = readKey()
        let previousActiveLine = state.activeLine
        if key.code == .up, state.activeLine > state.rangeOfLines.minimum {
            state.activeLine -= 1
        } else if key.code == .down, state.activeLine < state.rangeOfLines.maximum {
            state.activeLine += 1
        }
        
        reRender(state: state, previousActiveLine: previousActiveLine)
    }
    
    func reRender(state: SelectionState, previousActiveLine: Int) {
        let newActiveLine = state.activeLine
        [previousActiveLine, newActiveLine].forEach { line in
            if let option = state.options.first(where: { $0.line == line }) {
                let isActive = line == newActiveLine
                renderOption(option: option, isActive: isActive, row: line, col: 0)
            }
        }
    }
    
    func writeAt(_ row: Int, _ col: Int, _ text: String) {
        moveTo(row, col)
        write(text)
    }
    
    func enableNormalInput() {
        cursorOn()
        restoreDefaultTerminal()
    }
    
    func clearScreenIfRequired(shouldClear: Bool) {
        if shouldClear {
            clearScreen()
        }
    }
}
