//
//  MockSwiftPicker.swift
//  SwiftPicker
//
//  Created by Nikolai Nobadi on 2025-10-24.
//

import SwiftPicker

public class MockSwiftPicker {
    private let defaultInputValue: String
    private let grantPermissionByDefault: Bool
    private var mockInputType: MockInputType
    private var mockPermissionType: MockPermissionType

    public init(
        defaultInputValue: String = "",
        grantPermissionByDefault: Bool = true,
        mockInputType: MockInputType = .ordered([]),
        mockPermissionType: MockPermissionType = .ordered([]),
    ) {
        self.grantPermissionByDefault = grantPermissionByDefault
        self.defaultInputValue = defaultInputValue
        self.mockPermissionType = mockPermissionType
        self.mockInputType = mockInputType
    }
}


// MARK: - CommandLineInput
extension MockSwiftPicker: CommandLineInput {
    public func getInput(prompt: PickerPrompt) -> String {
        switch mockInputType {
        case .ordered(var responses):
            if responses.isEmpty {
                return defaultInputValue
            }

            let response = responses.removeFirst()

            mockInputType = .ordered(responses)

            return response
        case .dictionary(let dict):
            return dict[prompt.title] ?? defaultInputValue
        }
    }

    public func getRequiredInput(prompt: PickerPrompt) throws -> String {
        let input = getInput(prompt: prompt)

        guard !input.isEmpty else {
            throw SwiftPickerError.inputRequired
        }

        return input
    }
}


// MARK: - CommandLinePermission
extension MockSwiftPicker: CommandLinePermission {
    public func getPermission(prompt: PickerPrompt) -> Bool {
        switch mockPermissionType {
        case .ordered(var responses):
            if responses.isEmpty {
                return grantPermissionByDefault
            }
            
            let response = responses.removeFirst()
            
            mockPermissionType = .ordered(responses)
            
            return response
        case .dictionary(let dict):
            return dict[prompt.title] ?? grantPermissionByDefault
        }
    }

    public func requiredPermission(prompt: PickerPrompt) throws {
        guard getPermission(prompt: prompt) else {
            throw SwiftPickerError.selectionCancelled
        }
    }
}


// MARK: - CommandLineSelection
extension MockSwiftPicker: CommandLineSelection {
    public func singleSelection<Item: DisplayablePickerItem>(title: PickerPrompt, items: [Item]) -> Item? {
        fatalError() // TODO: -
    }
    
    public func requiredSingleSelection<Item: DisplayablePickerItem>(title: PickerPrompt, items: [Item]) throws -> Item {
        fatalError() // TODO: -
    }
    
    public func multiSelection<Item: DisplayablePickerItem>(title: PickerPrompt, items: [Item]) -> [Item] {
        fatalError() // TODO: -
    }
}


// MARK: - Dependencies
public enum MockPermissionType {
    case ordered([Bool])
    case dictionary([String: Bool])
}

public enum MockInputType {
    case ordered([String])
    case dictionary([String: String])
}
