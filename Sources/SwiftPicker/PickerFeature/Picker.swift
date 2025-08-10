//
//  Picker.swift
//  SwiftPicker
//
//  Created by Nikolai Nobadi on 3/26/25.
//

/// A protocol defining methods for command line text input.
public protocol CommandLineInput {
    /// Prompts the user for input with the given prompt.
    func getInput(prompt: PickerPrompt) -> String
    
    /// Prompts the user for input with the given prompt and requires non-empty input.
    func getRequiredInput(prompt: PickerPrompt) throws -> String
}

/// A protocol defining methods for command line yes/no permissions.
public protocol CommandLinePermission {
    /// Prompts the user for permission with a yes/no question.
    func getPermission(prompt: PickerPrompt) -> Bool
    
    /// Prompts the user for permission with a yes/no question and requires a yes to proceed.
    func requiredPermission(prompt: PickerPrompt) throws
}

/// A protocol defining methods for command line item selection.
public protocol CommandLineSelection {
    /// Prompts the user to make a single selection from a list of items.
    func singleSelection<Item: DisplayablePickerItem>(title: PickerPrompt, items: [Item]) -> Item?
    
    /// Prompts the user to make a single selection from a list of items and requires a selection.
    func requiredSingleSelection<Item: DisplayablePickerItem>(title: PickerPrompt, items: [Item]) throws -> Item
    
    /// Prompts the user to make multiple selections from a list of items.
    func multiSelection<Item: DisplayablePickerItem>(title: PickerPrompt, items: [Item]) -> [Item]
}

/// A unified protocol combining all command line interaction capabilities.
public typealias CommandLinePicker = CommandLineInput & CommandLinePermission & CommandLineSelection

/// Legacy protocol name for backward compatibility. Use `CommandLinePicker` instead.
@available(*, deprecated, renamed: "CommandLinePicker", message: "Use CommandLinePicker to avoid conflicts with SwiftUI.Picker")
public typealias Picker = CommandLinePicker


// MARK: - Input Convenience Methods
public extension CommandLineInput {
    func getInput(_ prompt: PickerPrompt) -> String {
        return getInput(prompt: prompt)
    }
    
    func getRequiredInput(_ prompt: PickerPrompt) throws -> String {
        return try getRequiredInput(prompt: prompt)
    }
}

// MARK: - Permission Convenience Methods
public extension CommandLinePermission {
    func getPermission(_ prompt: PickerPrompt) -> Bool {
        return getPermission(prompt: prompt)
    }
    
    func requiredPermission(_ prompt: PickerPrompt) throws {
        return try requiredPermission(prompt: prompt)
    }
}

// MARK: - Selection Convenience Methods
public extension CommandLineSelection {
    func singleSelection<Item: DisplayablePickerItem>(_ title: PickerPrompt, items: [Item]) -> Item? {
        return singleSelection(title: title, items: items)
    }
    
    func requiredSingleSelection<Item: DisplayablePickerItem>(_ title: PickerPrompt, items: [Item]) throws -> Item {
        return try requiredSingleSelection(title: title, items: items)
    }
    
    func multiSelection<Item: DisplayablePickerItem>(_ title: PickerPrompt, items: [Item]) -> [Item] {
        return multiSelection(title: title, items: items)
    }
}
