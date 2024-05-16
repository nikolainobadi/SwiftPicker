//
//  BaseSelectionHandler.swift
//
//
//  Created by Nikolai Nobadi on 5/16/24.
//

import ANSITerminal

internal class BaseSelectionHandler<Item: DisplayablePickerItem> {
    let padding: PickerPadding
    let inputHandler: PickerInput
    let state: SelectionState<Item>
    
    init(padding: PickerPadding, state: SelectionState<Item>, inputHandler: PickerInput) {
        self.state = state
        self.padding = padding
        self.inputHandler = inputHandler
    }
}


// MARK: - Actions
extension BaseSelectionHandler {
    func endSelection() {
        inputHandler.exitAlternativeScreen()
        inputHandler.enableNormalInput()
    }
    
    func scrollAndRenderOptions() {
        let (rows, _) = inputHandler.readScreenSize()
        let displayableOptionsCount = rows - verticalPadding
        
        renderScrollableOptions(displayableOptionsCount: displayableOptionsCount)
    }
    
    func handleArrowKeys() {
        guard let directionKey = inputHandler.readDirectionKey() else { return }
        
        switch directionKey {
        case .up:
            if state.activeLine > state.rangeOfLines.minimum {
                handleScrolling(direction: -1)
            }
        case .down:
            handleScrolling(direction: 1)
        }
    }
}


// MARK: - Private Methods
private extension BaseSelectionHandler {
    var topPadding: Int { padding.top }
    var bottomPadding: Int { padding.bottom }
    var verticalPadding: Int { topPadding + bottomPadding }
    
    func handleScrolling(direction: Int) {
        state.activeLine = max(0, min(state.options.count + topPadding, state.activeLine + direction))
        scrollAndRenderOptions()
    }
    
    func renderScrollableOptions(displayableOptionsCount: Int) {
        let start = max(0, state.activeLine - (displayableOptionsCount + topPadding))
        let end = min((start + displayableOptionsCount), state.options.count)
        
        inputHandler.clearScreen()
        inputHandler.moveToHome()
        inputHandler.write(state.title + String(repeating: "\n", count: topPadding))
        
        for i in start..<end {
            let option = state.options[i]
            renderOption(option: option, isActive: option.line == state.activeLine, row: i - start + (topPadding + 1), col: 0)
        }
        
        inputHandler.write("\(String(repeating: "\n", count: bottomPadding))start: \(start + 1), activeLine: \(state.activeLine), otherStart: (\(state.activeLine - (displayableOptionsCount + topPadding))) end: \(end)")
    }
    
    func renderOption(option: Option<Item>, isActive: Bool, row: Int, col: Int = 0) {
        inputHandler.moveTo(row, col)
        inputHandler.write("│".foreColor(81))
        inputHandler.moveRight()
        inputHandler.write(option.isSelected ? "●".lightGreen : "○".foreColor(250))
        inputHandler.moveRight()
        inputHandler.write(isActive ? option.title.underline : option.title.foreColor(250))
    }
}


// MARK: - Extension Dependencies
extension Option {
    var title: String {
        return item.displayName
    }
}
