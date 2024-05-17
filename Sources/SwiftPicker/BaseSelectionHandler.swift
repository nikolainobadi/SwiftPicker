//
//  BaseSelectionHandler.swift
//
//
//  Created by Nikolai Nobadi on 5/16/24.
//

import ANSITerminal

enum PickerPadding {
    static let top = 4
    static let bottom = 2
}

internal class BaseSelectionHandler<Item: DisplayablePickerItem> {
    let inputHandler: PickerInput
    let state: SelectionState<Item>
    
    init(state: SelectionState<Item>, inputHandler: PickerInput) {
        self.state = state
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
    var topPadding: Int { PickerPadding.top }
    var bottomPadding: Int { PickerPadding.bottom }
    var verticalPadding: Int { topPadding + bottomPadding }
    
    func handleScrolling(direction: Int) {
        state.activeLine = max(0, min(state.options.count + topPadding, state.activeLine + direction))
        scrollAndRenderOptions()
    }
    
    func renderScrollableOptions(displayableOptionsCount: Int) {
        let start = max(0, state.activeLine - (displayableOptionsCount + topPadding))
        let end = min((start + displayableOptionsCount), state.options.count)
        let (_, columns) = inputHandler.readScreenSize()
        let title = "\(centerText("SwiftPicker", inWidth: columns))\n\n\(state.title)\n"
    
        inputHandler.clearScreen()
        inputHandler.moveToHome()
        inputHandler.write(title)
        
        for i in start..<end {
            let option = state.options[i]
            renderOption(option: option, isActive: option.line == state.activeLine, row: i - start + (topPadding + 1), col: 0)
        }
        
        inputHandler.write("\n\nTap 'enter' to select. Type 'q' to quit")
    }
    
    func centerText(_ text: String, inWidth width: Int) -> String {
        let textLength = text.count
        let spaces = (width - textLength) / 2
        let padding = String(repeating: " ", count: max(0, spaces))
        return padding + text
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
