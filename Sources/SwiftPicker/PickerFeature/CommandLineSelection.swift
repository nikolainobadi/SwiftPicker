//
//  CommandLineSelection.swift
//  SwiftPicker
//
//  Created by Nikolai Nobadi on 3/26/25.
//

/// A protocol defining methods for command line item selection.
public protocol CommandLineSelection {
    /// Prompts the user to make a single selection from a list of items.
    func singleSelection<Item: DisplayablePickerItem>(title: PickerPrompt, items: [Item]) -> Item?
    
    /// Prompts the user to make a single selection from a list of items and requires a selection.
    func requiredSingleSelection<Item: DisplayablePickerItem>(title: PickerPrompt, items: [Item]) throws -> Item
    
    /// Prompts the user to make multiple selections from a list of items.
    func multiSelection<Item: DisplayablePickerItem>(title: PickerPrompt, items: [Item]) -> [Item]
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