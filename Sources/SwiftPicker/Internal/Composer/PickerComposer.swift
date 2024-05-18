//
//  PickerComposer.swift
//
//
//  Created by Nikolai Nobadi on 5/16/24.
//



//// PickerComposer.swift
////// Created by Nikolai Nobadi on 5/16/24.

/// An enumeration that composes various handlers for SwiftPicker.
/// Provides methods to create single and multi-selection handlers.
internal enum PickerComposer {
    
    /// The input handler for reading user input and controlling the terminal.
    static var inputHandler: PickerInput = PickerInputAdapter()
}

// MARK: - Composer
internal extension PickerComposer {
    /// Creates a single selection handler with the provided information.
    /// - Parameters:
    ///   - info: The PickerInfo object containing the title and items.
    ///   - newScreen: A Boolean value indicating whether to show a new screen.
    /// - Returns: A SingleSelectionHandler instance.
    static func makeSingleSelectionHandler<Item: DisplayablePickerItem>(info: PickerInfo<Item>, newScreen: Bool) -> SingleSelectionHandler<Item> {
        let state = makeState(info: info, newScreen: newScreen, isSingleSelection: true)
        return .init(state: state, inputHandler: inputHandler)
    }
    
    /// Creates a multi-selection handler with the provided information.
    /// - Parameters:
    ///   - info: The PickerInfo object containing the title and items.
    ///   - newScreen: A Boolean value indicating whether to show a new screen.
    /// - Returns: A MultiSelectionHandler instance.
    static func makeMultiSelectionHandler<Item: DisplayablePickerItem>(info: PickerInfo<Item>, newScreen: Bool) -> MultiSelectionHandler<Item> {
        let state = makeState(info: info, newScreen: newScreen, isSingleSelection: false)
        return .init(state: state, inputHandler: inputHandler)
    }
}

// MARK: - Private Methods
private extension PickerComposer {
    /// Creates a selection state with the provided information.
    /// - Parameters:
    ///   - info: The PickerInfo object containing the title and items.
    ///   - newScreen: A Boolean value indicating whether to show a new screen.
    ///   - isSingleSelection: A Boolean value indicating whether the selection mode is single selection.
    /// - Returns: A SelectionState instance.
    static func makeState<Item: DisplayablePickerItem>(info: PickerInfo<Item>, newScreen: Bool, isSingleSelection: Bool) -> SelectionState<Item> {
        configureScreen(newScreen)
        let topLine = inputHandler.readCursorPos().row + PickerPadding.top
        let options = makeOptions(items: info.items, topLine: topLine)
        return .init(options: options, topLine: topLine, title: info.title, isSingleSelection: isSingleSelection)
    }
    
    /// Configures the screen for selection.
    /// - Parameter newScreen: A Boolean value indicating whether to show a new screen.
    static func configureScreen(_ newScreen: Bool) {
        if (newScreen) { inputHandler.enterAlternativeScreen() }
        inputHandler.cursorOff()
        inputHandler.clearScreen()
        inputHandler.moveToHome()
    }
    
    /// Creates an array of options from the provided items.
    /// - Parameters:
    ///   - items: The list of items to select from.
    ///   - topLine: The line position of the top line in the selection list.
    /// - Returns: An array of Option instances.
    static func makeOptions<Item: DisplayablePickerItem>(items: [Item], topLine: Int) -> [Option<Item>] {
        return items.enumerated().map { .init(item: $1, line: topLine + $0) }
    }
}
