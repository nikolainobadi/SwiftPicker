//
//  BaseSelectionHandler.swift
//
//
//  Created by Nikolai Nobadi on 5/16/24.
//

import ANSITerminal

/// A base class for handling selection logic in SwiftPicker.
/// It manages the user input and rendering of options for both single and multi-selection modes.
class BaseSelectionHandler<Item: DisplayablePickerItem> {
    /// The input handler for reading user input and controlling the terminal.
    let inputHandler: PickerInput
    
    /// The current state of the selection process.
    let state: SelectionState<Item>
    
    /// Initializes a new instance of BaseSelectionHandler.
    /// - Parameters:
    ///   - state: The current state of the selection process.
    ///   - inputHandler: The input handler for reading user input and controlling the terminal.
    init(state: SelectionState<Item>, inputHandler: PickerInput) {
        self.state = state
        self.inputHandler = inputHandler
    }
}


// MARK: - Actions
extension BaseSelectionHandler {
    /// Ends the selection process and restores the terminal to its normal state.
    func endSelection() {
        inputHandler.exitAlternativeScreen()
        inputHandler.enableNormalInput()
    }
    
    /// Scrolls and renders the options in the selection list based on the terminal size.
    func scrollAndRenderOptions() {
        let (rows, cols) = inputHandler.readScreenSize()
        let displayableOptionsCount = rows - verticalPadding
        
        renderScrollableOptions(displayableOptionsCount: displayableOptionsCount, columns: cols)
    }
    
    /// Handles the user's arrow key inputs to navigate the selection list.
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
    /// The top padding to be applied in the selection list.
    var topPadding: Int { PickerPadding.top }
    
    /// The bottom padding to be applied in the selection list.
    var bottomPadding: Int { PickerPadding.bottom }
    
    /// The total vertical padding to be applied in the selection list.
    var verticalPadding: Int { topPadding + bottomPadding }
    
    /// Handles the scrolling of the selection list in the specified direction.
    /// - Parameter direction: The direction to scroll (-1 for up, 1 for down).
    func handleScrolling(direction: Int) {
        state.activeLine = max(0, min(state.options.count + topPadding, state.activeLine + direction))
        scrollAndRenderOptions()
    }
    
    /// Renders the options in the selection list with scrolling support.
    /// - Parameters:
    ///   - displayableOptionsCount: The number of options that can be displayed at once.
    ///   - columns: The number of columns in the terminal.
    func renderScrollableOptions(displayableOptionsCount: Int, columns: Int) {
        let start = max(0, state.activeLine - (displayableOptionsCount + topPadding))
        let end = min((start + displayableOptionsCount), state.options.count)
    
        renderHeader(start: start, columns: columns)
        
        for i in start..<end {
            let option = state.options[i]
            let isActive = option.line == state.activeLine
            let row = i - start + (topPadding + 1)
            
            renderOption(option: option, isActive: isActive, row: row, col: 0)
        }
        
        renderFooter(end: end, displayableOptionsCount: displayableOptionsCount)
    }
    
    /// Renders the header of the selection list.
    /// - Parameters:
    ///   - start: The starting index of the options to display.
    ///   - columns: The number of columns in the terminal.
    func renderHeader(start: Int, columns: Int) {
        inputHandler.clearScreen()
        inputHandler.moveToHome()
        inputHandler.write(centerText(state.topLineText, inWidth: columns))
        inputHandler.write("\n")
        inputHandler.write("\n")
        inputHandler.write(state.title)
        inputHandler.write("\n")
        if start > 0 {
            inputHandler.write("↑".lightGreen)
        }
    }
    
    /// Renders the footer of the selection list.
    /// - Parameters:
    ///   - end: The ending index of the options to display.
    ///   - displayableOptionsCount: The number of options that can be displayed at once.
    func renderFooter(end: Int, displayableOptionsCount: Int) {
        inputHandler.write("\n")
        if state.options.count > displayableOptionsCount {
            if end < state.options.count {
                inputHandler.write("↓".lightGreen)
            }
            
        }
        inputHandler.write("\n")
        inputHandler.write(state.bottomLineText)
    }
    
    /// Centers the given text within the specified width.
    /// - Parameters:
    ///   - text: The text to center.
    ///   - width: The width within which to center the text.
    /// - Returns: The centered text.
    func centerText(_ text: String, inWidth width: Int) -> String {
        let textLength = text.count
        let spaces = (width - textLength) / 2
        let padding = String(repeating: " ", count: max(0, spaces))
        
        return padding + text
    }
    
    /// Renders a single option in the selection list.
    /// - Parameters:
    ///   - option: The option to render.
    ///   - isActive: A Boolean value indicating whether the option is currently active.
    ///   - row: The row position of the option.
    ///   - col: The column position of the option.
    func renderOption(option: Option<Item>, isActive: Bool, row: Int, col: Int = 0) {
        inputHandler.moveTo(row, col)
        inputHandler.moveRight()
        inputHandler.write(state.showAsSelected(option) ? "●".lightGreen : "○".foreColor(250))
        inputHandler.moveRight()
        inputHandler.write(isActive ? option.title.underline : option.title.foreColor(250))
    }
}


// MARK: - Extension Dependencies
private extension SelectionState {
    /// Determines whether an option should be shown as selected.
    /// - Parameter option: The option to check.
    /// - Returns: A Boolean value indicating whether the option is selected.
    func showAsSelected(_ option: Option<Item>) -> Bool {
        return isSingleSelection ? option.line == activeLine : option.isSelected
    }
}
