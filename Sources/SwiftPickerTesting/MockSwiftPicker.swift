//
//  MockSwiftPicker.swift
//  SwiftPicker
//
//  Created by Nikolai Nobadi on 2025-10-24.
//

import SwiftPicker

/// A mock implementation of `CommandLinePicker` for testing purposes.
///
/// `MockSwiftPicker` provides a configurable mock that conforms to `CommandLineInput`,
/// `CommandLinePermission`, and `CommandLineSelection` protocols. It allows you to
/// pre-configure responses for input prompts, permission requests, and item selections,
/// making it ideal for unit testing code that depends on user interaction.
///
/// ## Usage Examples
///
/// ### Basic Input Testing
/// ```swift
/// // Test with ordered responses
/// let mock = MockSwiftPicker(
///     inputResult: .init(type: .ordered(["Alice", "Bob"]))
/// )
///
/// let name = mock.getInput(prompt: "Name:")  // Returns "Alice"
/// let email = mock.getInput(prompt: "Email:")  // Returns "Bob"
/// ```
///
/// ### Permission Testing
/// ```swift
/// // Test permission flow
/// let mock = MockSwiftPicker(
///     permissionResult: .init(
///         grantByDefault: false,
///         type: .ordered([true, false])
///     )
/// )
///
/// let canContinue = mock.getPermission(prompt: "Continue?")  // Returns true
/// let canDelete = mock.getPermission(prompt: "Delete?")  // Returns false
/// ```
///
/// ### Selection Testing
/// ```swift
/// // Test single selection
/// let items = ["Apple", "Banana", "Cherry"]
/// let mock = MockSwiftPicker(
///     selectionResult: .init(singleSelectionType: .ordered([1]))
/// )
///
/// let selected = mock.singleSelection(title: "Choose fruit:", items: items)
/// // Returns "Banana" (item at index 1)
/// ```
///
/// ### Dictionary-Based Responses
/// ```swift
/// // Use dictionary for prompt-specific responses
/// let mock = MockSwiftPicker(
///     inputResult: .init(type: .dictionary([
///         "Name:": "Alice",
///         "Email:": "alice@example.com"
///     ])),
///     permissionResult: .init(type: .dictionary([
///         "Continue?": true,
///         "Delete?": false
///     ]))
/// )
///
/// let name = mock.getInput(prompt: "Name:")  // Returns "Alice"
/// let canDelete = mock.getPermission(prompt: "Delete?")  // Returns false
/// ```
///
/// ### Multi-Selection Testing
/// ```swift
/// // Test multiple item selection
/// let items = ["Red", "Green", "Blue", "Yellow"]
/// let mock = MockSwiftPicker(
///     selectionResult: .init(
///         multiSelectionType: .ordered([[0, 2], [1, 3]])
///     )
/// )
///
/// let colors1 = mock.multiSelection(title: "Pick colors:", items: items)
/// // Returns ["Red", "Blue"] (items at indices 0 and 2)
///
/// let colors2 = mock.multiSelection(title: "Pick colors:", items: items)
/// // Returns ["Green", "Yellow"] (items at indices 1 and 3)
/// ```
///
/// ## Response Types
///
/// - **Ordered**: Responses are consumed in sequence (FIFO)
/// - **Dictionary**: Responses are matched by prompt title
/// - **Default Values**: Used when ordered responses are exhausted or dictionary has no match
///
/// ## Testing Errors
///
/// ```swift
/// // Test required input with empty response
/// let mock = MockSwiftPicker(
///     inputResult: .init(defaultValue: "", type: .ordered([]))
/// )
///
/// // This will throw SwiftPickerError.inputRequired
/// try mock.getRequiredInput(prompt: "Name:")
///
/// // Test selection cancellation
/// let mock2 = MockSwiftPicker(
///     selectionResult: .init(singleSelectionType: .ordered([nil]))
/// )
///
/// // This will throw SwiftPickerError.selectionCancelled
/// try mock2.requiredSingleSelection(title: "Choose:", items: ["A", "B"])
/// ```
public class MockSwiftPicker {
    private var inputResult: MockInputResult
    private var permissionResult: MockPermissionResult
    private var selectionResult: MockSelectionResult

    /// Creates a new `MockSwiftPicker` instance with configurable response behaviors.
    ///
    /// - Parameters:
    ///   - inputResult: Configuration for text input responses. Defaults to empty ordered responses.
    ///   - permissionResult: Configuration for permission responses. Defaults to granting all permissions.
    ///   - selectionResult: Configuration for selection responses. Defaults to selecting index 0.
    ///
    /// ## Example
    /// ```swift
    /// let mock = MockSwiftPicker(
    ///     inputResult: .init(
    ///         defaultValue: "default",
    ///         type: .ordered(["response1", "response2"])
    ///     ),
    ///     permissionResult: .init(
    ///         grantByDefault: true,
    ///         type: .ordered([true, false])
    ///     ),
    ///     selectionResult: .init(
    ///         defaultIndex: 0,
    ///         singleSelectionType: .ordered([1, 2]),
    ///         multiSelectionType: .ordered([[0, 1]])
    ///     )
    /// )
    /// ```
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
    /// Returns a pre-configured text input response.
    ///
    /// - Parameter prompt: The prompt to display (used for dictionary lookup).
    /// - Returns: The next ordered response, dictionary-matched response, or default value.
    ///
    /// ## Behavior
    /// - **Ordered**: Returns and removes the first response from the queue
    /// - **Dictionary**: Returns the value matching `prompt.title`
    /// - **Fallback**: Returns `defaultValue` when no response is available
    ///
    /// ## Example
    /// ```swift
    /// let mock = MockSwiftPicker(
    ///     inputResult: .init(
    ///         defaultValue: "default",
    ///         type: .ordered(["Alice", "Bob"])
    ///     )
    /// )
    ///
    /// mock.getInput(prompt: "Name:")  // "Alice"
    /// mock.getInput(prompt: "Name:")  // "Bob"
    /// mock.getInput(prompt: "Name:")  // "default"
    /// ```
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

    /// Returns a pre-configured text input response, throwing an error if empty.
    ///
    /// - Parameter prompt: The prompt to display (used for dictionary lookup).
    /// - Returns: The input response if non-empty.
    /// - Throws: `SwiftPickerError.inputRequired` if the response is empty.
    ///
    /// ## Example
    /// ```swift
    /// let mock = MockSwiftPicker(
    ///     inputResult: .init(type: .ordered(["Alice", ""]))
    /// )
    ///
    /// try mock.getRequiredInput(prompt: "Name:")  // "Alice"
    /// try mock.getRequiredInput(prompt: "Name:")  // Throws SwiftPickerError.inputRequired
    /// ```
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
    /// Returns a pre-configured permission response.
    ///
    /// - Parameter prompt: The prompt to display (used for dictionary lookup).
    /// - Returns: The next ordered response, dictionary-matched response, or default grant value.
    ///
    /// ## Behavior
    /// - **Ordered**: Returns and removes the first response from the queue
    /// - **Dictionary**: Returns the value matching `prompt.title`
    /// - **Fallback**: Returns `grantByDefault` when no response is available
    ///
    /// ## Example
    /// ```swift
    /// let mock = MockSwiftPicker(
    ///     permissionResult: .init(
    ///         grantByDefault: false,
    ///         type: .ordered([true, false, true])
    ///     )
    /// )
    ///
    /// mock.getPermission(prompt: "Continue?")  // true
    /// mock.getPermission(prompt: "Continue?")  // false
    /// mock.getPermission(prompt: "Continue?")  // true
    /// mock.getPermission(prompt: "Continue?")  // false (default)
    /// ```
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

    /// Requires permission, throwing an error if denied.
    ///
    /// - Parameter prompt: The prompt to display (used for dictionary lookup).
    /// - Throws: `SwiftPickerError.selectionCancelled` if permission is denied.
    ///
    /// ## Example
    /// ```swift
    /// let mock = MockSwiftPicker(
    ///     permissionResult: .init(type: .ordered([true, false]))
    /// )
    ///
    /// try mock.requiredPermission(prompt: "Continue?")  // Success
    /// try mock.requiredPermission(prompt: "Continue?")  // Throws SwiftPickerError.selectionCancelled
    /// ```
    public func requiredPermission(prompt: PickerPrompt) throws {
        guard getPermission(prompt: prompt) else {
            throw SwiftPickerError.selectionCancelled
        }
    }
}


// MARK: - CommandLineSelection
extension MockSwiftPicker: CommandLineSelection {
    /// Returns a pre-configured single item selection.
    ///
    /// - Parameters:
    ///   - title: The prompt to display (used for dictionary lookup).
    ///   - items: The list of items to select from.
    /// - Returns: The item at the configured index, or `nil` if cancelled or index is invalid.
    ///
    /// ## Behavior
    /// - **Ordered**: Returns item at next index from queue (consumes the index)
    /// - **Dictionary**: Returns item at index matching `title`
    /// - **Fallback**: Returns item at `defaultIndex` when queue is empty
    /// - **Cancellation**: Returns `nil` when configured index is `nil`
    /// - **Invalid Index**: Returns `nil` when index is out of bounds
    ///
    /// ## Example
    /// ```swift
    /// let items = ["Apple", "Banana", "Cherry"]
    /// let mock = MockSwiftPicker(
    ///     selectionResult: .init(
    ///         defaultIndex: 0,
    ///         singleSelectionType: .ordered([1, nil, 2])
    ///     )
    /// )
    ///
    /// mock.singleSelection(title: "Pick:", items: items)  // "Banana" (index 1)
    /// mock.singleSelection(title: "Pick:", items: items)  // nil (cancelled)
    /// mock.singleSelection(title: "Pick:", items: items)  // "Cherry" (index 2)
    /// mock.singleSelection(title: "Pick:", items: items)  // "Apple" (default index 0)
    /// ```
    public func singleSelection<Item: DisplayablePickerItem>(title: PickerPrompt, items: [Item]) -> Item? {
        guard let index = getSelectionIndex(prompt: title) else {
            return nil
        }

        guard items.indices.contains(index) else {
            return nil
        }

        return items[index]
    }

    /// Returns a pre-configured single item selection, throwing an error if cancelled.
    ///
    /// - Parameters:
    ///   - title: The prompt to display (used for dictionary lookup).
    ///   - items: The list of items to select from.
    /// - Returns: The selected item.
    /// - Throws: `SwiftPickerError.selectionCancelled` if selection is cancelled or invalid.
    ///
    /// ## Example
    /// ```swift
    /// let items = ["Red", "Green", "Blue"]
    /// let mock = MockSwiftPicker(
    ///     selectionResult: .init(singleSelectionType: .ordered([1, nil]))
    /// )
    ///
    /// try mock.requiredSingleSelection(title: "Color:", items: items)  // "Green"
    /// try mock.requiredSingleSelection(title: "Color:", items: items)  // Throws
    /// ```
    public func requiredSingleSelection<Item: DisplayablePickerItem>(title: PickerPrompt, items: [Item]) throws -> Item {
        guard let item = singleSelection(title: title, items: items) else {
            throw SwiftPickerError.selectionCancelled
        }

        return item
    }

    /// Returns a pre-configured multiple item selection.
    ///
    /// - Parameters:
    ///   - title: The prompt to display (used for dictionary lookup).
    ///   - items: The list of items to select from.
    /// - Returns: The items at the configured indices. Returns empty array if cancelled or no valid indices.
    ///
    /// ## Behavior
    /// - **Ordered**: Returns items at next indices array from queue (consumes the array)
    /// - **Dictionary**: Returns items at indices matching `title`
    /// - **Fallback**: Returns empty array when queue is empty
    /// - **Cancellation**: Returns empty array when configured with empty indices `[]`
    /// - **Invalid Indices**: Filters out indices that are out of bounds
    ///
    /// ## Example
    /// ```swift
    /// let items = ["Red", "Green", "Blue", "Yellow"]
    /// let mock = MockSwiftPicker(
    ///     selectionResult: .init(
    ///         multiSelectionType: .ordered([
    ///             [0, 2],      // First call: Red, Blue
    ///             [1, 3],      // Second call: Green, Yellow
    ///             [],          // Third call: cancelled (empty)
    ///             [0, 10, 2]   // Fourth call: Red, Blue (10 is invalid, filtered out)
    ///         ])
    ///     )
    /// )
    ///
    /// mock.multiSelection(title: "Colors:", items: items)  // ["Red", "Blue"]
    /// mock.multiSelection(title: "Colors:", items: items)  // ["Green", "Yellow"]
    /// mock.multiSelection(title: "Colors:", items: items)  // [] (cancelled)
    /// mock.multiSelection(title: "Colors:", items: items)  // ["Red", "Blue"]
    /// mock.multiSelection(title: "Colors:", items: items)  // [] (queue exhausted)
    /// ```
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
