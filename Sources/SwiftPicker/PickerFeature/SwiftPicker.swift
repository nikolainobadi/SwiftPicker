//
//  SwiftPicker.swift
//
//
//  Created by Nikolai Nobadi on 5/16/24.
//

/// SwiftPicker is a command-line tool written in Swift that allows for interactive selection of items.
/// It supports both single and multiple selection modes.
public struct SwiftPicker: Picker {
    
    /// Initializes a new instance of `SwiftPicker`.
    public init() { }
}

// MARK: - Input
public extension SwiftPicker {
    /// Prompts the user for input with the given prompt string.
    /// - Parameter prompt: The prompt message to display to the user.
    /// - Returns: The user's input as a String.
    func getInput(prompt: PickerPrompt) -> String {
        return InputHandler.getInput(prompt.title)
    }
    
    /// Prompts the user for input with the given prompt string and requires input.
    /// - Parameter prompt: The prompt message to display to the user.
    /// - Throws: `SwiftPickerError.inputRequired` if the user does not provide any input.
    /// - Returns: The user's input as a String.
    func getRequiredInput(prompt: PickerPrompt) throws -> String {
        let input = getInput(prompt)
        if input.isEmpty {
            throw SwiftPickerError.inputRequired
        }
        return input
    }
}

// MARK: - Permission
public extension SwiftPicker {
    /// Prompts the user for permission with a yes/no question.
    /// - Parameter prompt: The prompt message to display to the user.
    /// - Returns: `true` if the user grants permission, `false` otherwise.
    func getPermission(prompt: PickerPrompt) -> Bool {
        return InputHandler.getPermission(prompt.title)
    }
    
    /// Prompts the user for permission with a yes/no question and requires a yes to proceed.
    /// - Parameter prompt: The prompt message to display to the user.
    /// - Throws: `SwiftPickerError.selectionCancelled` if the user does not grant permission.
    func requiredPermission(prompt: PickerPrompt) throws {
        guard getPermission(prompt: prompt) else {
            throw SwiftPickerError.selectionCancelled
        }
    }
}

// MARK: - SingleSelection
public extension SwiftPicker {
    /// Prompts the user to make a single selection from a list of items.
    /// - Parameters:
    ///   - title: The title to display at the top of the selection list.
    ///   - items: The list of items to select from.
    /// - Returns: The selected item, or `nil` if no selection was made.
    func singleSelection<Item: DisplayablePickerItem>(title: PickerPrompt, items: [Item]) -> Item? {
        let info = makeInfo(title: title.title, items: items)
        return captureSingleInput(info: info, showNewScreen: true)
    }
    
    /// Prompts the user to make a single selection from a list of items and requires a selection.
    /// - Parameters:
    ///   - title: The title to display at the top of the selection list.
    ///   - items: The list of items to select from.
    /// - Throws: `SwiftPickerError.selectionCancelled` if the user does not make a selection.
    /// - Returns: The selected item.
    func requiredSingleSelection<Item: DisplayablePickerItem>(title: PickerPrompt, items: [Item]) throws -> Item {
        guard let selection = singleSelection(title: title, items: items) else {
            throw SwiftPickerError.selectionCancelled
        }
        return selection
    }
}

// MARK: - MultiSelection
public extension SwiftPicker {
    /// Prompts the user to make multiple selections from a list of items.
    /// - Parameters:
    ///   - title: The title to display at the top of the selection list.
    ///   - items: The list of items to select from.
    /// - Returns: An array of selected items.
    func multiSelection<Item: DisplayablePickerItem>(title: PickerPrompt, items: [Item]) -> [Item] {
        let info = makeInfo(title: title.title, items: items)
        return captureMultiInput(info: info, showNewScreen: true)
    }
}

// MARK: - Private Methods
private extension SwiftPicker {
    /// Creates a `PickerInfo` object with the given title and items.
    /// - Parameters:
    ///   - title: The title to display at the top of the selection list.
    ///   - items: The list of items to select from.
    /// - Returns: A PickerInfo object containing the title and items.
    func makeInfo<Item: DisplayablePickerItem>(title: String, items: [Item]) -> PickerInfo<Item> {
        return .init(title: title, items: items)
    }
    
    /// Captures user input for a single selection.
    /// - Parameters:
    ///   - info: The `PickerInfo` object containing the title and items.
    ///   - showNewScreen: A Boolean value indicating whether to show a new screen.
    /// - Returns: The selected item, or `nil` if no selection was made.
    func captureSingleInput<Item: DisplayablePickerItem>(info: PickerInfo<Item>, showNewScreen: Bool) -> Item? {
        let handler = PickerComposer.makeSingleSelectionHandler(info: info, newScreen: showNewScreen)
        let selection = handler.captureUserInput()
        
        handler.endSelection()
        handler.printResult(selection?.displayName)
        
        return selection
    }
    
    /// Captures user input for multiple selections.
    /// - Parameters:
    ///   - info: The `PickerInfo` object containing the title and items.
    ///   - showNewScreen: A Boolean value indicating whether to show a new screen.
    /// - Returns: An array of selected items.
    func captureMultiInput<Item: DisplayablePickerItem>(info: PickerInfo<Item>, showNewScreen: Bool) -> [Item] {
        let handler = PickerComposer.makeMultiSelectionHandler(info: info, newScreen: showNewScreen)
        let selections = handler.captureUserInput()
        
        handler.endSelection()
        handler.printResults(selections.map({ $0.displayName }))
        
        return selections
    }
}
