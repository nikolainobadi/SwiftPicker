//
//  MockSwiftPicker.swift
//  SwiftPicker
//
//  Created by Nikolai Nobadi on 2025-10-24.
//

import SwiftPicker

public class MockSwiftPicker {
    private var inputResult: MockInputResult
    private var permissionResult: MockPermissionResult
    private var selectionResult: MockSelectionResult

    public init(
        inputResult: MockInputResult = .init(),
        permissionResult: MockPermissionResult = .init(),
        selectionResult: MockSelectionResult = .init()
    ) {
        self.inputResult = inputResult
        self.permissionResult = permissionResult
        self.selectionResult = selectionResult
    }
}


// MARK: - CommandLineInput
extension MockSwiftPicker: CommandLineInput {
    public func getInput(prompt: PickerPrompt) -> String {
        switch inputResult.type {
        case .ordered(var responses):
            if responses.isEmpty {
                return inputResult.defaultValue
            }

            let response = responses.removeFirst()

            inputResult.type = .ordered(responses)

            return response
        case .dictionary(let dict):
            return dict[prompt.title] ?? inputResult.defaultValue
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
        switch permissionResult.type {
        case .ordered(var responses):
            if responses.isEmpty {
                return permissionResult.grantByDefault
            }

            let response = responses.removeFirst()

            permissionResult.type = .ordered(responses)

            return response
        case .dictionary(let dict):
            return dict[prompt.title] ?? permissionResult.grantByDefault
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
        guard let index = getSelectionIndex(prompt: title) else {
            return nil
        }

        guard items.indices.contains(index) else {
            return nil
        }

        return items[index]
    }

    public func requiredSingleSelection<Item: DisplayablePickerItem>(title: PickerPrompt, items: [Item]) throws -> Item {
        guard let item = singleSelection(title: title, items: items) else {
            throw SwiftPickerError.selectionCancelled
        }

        return item
    }

    public func multiSelection<Item: DisplayablePickerItem>(title: PickerPrompt, items: [Item]) -> [Item] {
        let indices = getMultiSelectionIndices(prompt: title)

        return indices.compactMap { items.indices.contains($0) ? items[$0] : nil }
    }
}


// MARK: - Helpers
private extension MockSwiftPicker {
    func getSelectionIndex(prompt: PickerPrompt) -> Int? {
        switch selectionResult.singleSelectionType {
        case .ordered(var responses):
            if responses.isEmpty {
                return selectionResult.defaultIndex
            }

            let response = responses.removeFirst()

            selectionResult.singleSelectionType = .ordered(responses)

            return response
        case .dictionary(let dict):
            return dict[prompt.title] ?? selectionResult.defaultIndex
        }
    }

    func getMultiSelectionIndices(prompt: PickerPrompt) -> [Int] {
        switch selectionResult.multiSelectionType {
        case .ordered(var responses):
            if responses.isEmpty {
                return []
            }

            let response = responses.removeFirst()

            selectionResult.multiSelectionType = .ordered(responses)

            return response
        case .dictionary(let dict):
            return dict[prompt.title] ?? []
        }
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

public enum MockSelectionType {
    case ordered([Int?])
    case dictionary([String: Int?])
}

public enum MockMultiSelectionType {
    case ordered([[Int]])
    case dictionary([String: [Int]])
}

public struct MockInputResult {
    public let defaultValue: String
    public var type: MockInputType

    public init(defaultValue: String = "", type: MockInputType = .ordered([])) {
        self.defaultValue = defaultValue
        self.type = type
    }
}

public struct MockPermissionResult {
    public let grantByDefault: Bool
    public var type: MockPermissionType

    public init(grantByDefault: Bool = true, type: MockPermissionType = .ordered([])) {
        self.grantByDefault = grantByDefault
        self.type = type
    }
}

public struct MockSelectionResult {
    public let defaultIndex: Int?
    public var singleSelectionType: MockSelectionType
    public var multiSelectionType: MockMultiSelectionType

    public init(
        defaultIndex: Int? = 0,
        singleSelectionType: MockSelectionType = .ordered([]),
        multiSelectionType: MockMultiSelectionType = .ordered([])
    ) {
        self.defaultIndex = defaultIndex
        self.singleSelectionType = singleSelectionType
        self.multiSelectionType = multiSelectionType
    }
}
