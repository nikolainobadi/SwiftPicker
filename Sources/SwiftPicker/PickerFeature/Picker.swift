//
//  Picker.swift
//  SwiftPicker
//
//  Created by Nikolai Nobadi on 3/26/25.
//

/// A protocol defining methods for user interaction and input retrieval.
public protocol Picker {
    // basic input
    func getInput(prompt: PickerPrompt) -> String
    func getRequiredInput(prompt: PickerPrompt) throws -> String
    
    // permissions (y/n)
    func getPermission(prompt: PickerPrompt) -> Bool
    func requiredPermission(prompt: PickerPrompt) throws
    
    // selections
    func singleSelection<Item: DisplayablePickerItem>(title: PickerPrompt, items: [Item]) -> Item?
    func requiredSingleSelection<Item: DisplayablePickerItem>(title: PickerPrompt, items: [Item]) throws -> Item
    func multiSelection<Item: DisplayablePickerItem>(title: PickerPrompt, items: [Item]) -> [Item]
}


// MARK: - Alternatives
public extension Picker {
    func getInput(_ prompt: PickerPrompt) -> String {
        return getInput(prompt: prompt)
    }
    
    func getRequiredInput(_ prompt: PickerPrompt) throws -> String {
        return try getRequiredInput(prompt: prompt)
    }
    
    func getPermission(_ prompt: PickerPrompt) -> Bool {
        return getPermission(prompt: prompt)
    }
    
    func requiredPermission(_ prompt: PickerPrompt) throws {
        return try requiredPermission(prompt: prompt)
    }
    
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
