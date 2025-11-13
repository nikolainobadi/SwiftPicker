//
//  InteractivePicker.swift
//
//
//  Created by Nikolai Nobadi on 5/16/24.
//

/// InteractivePicker is a command-line tool written in Swift that allows for interactive selection of items.
/// It supports both single and multiple selection modes.
public struct InteractivePicker: CommandLinePicker {
    /// Handler for text input and permission prompts.
    private let textInputHandler: TextInputHandler
    /// Handler for picker-specific input (navigation, selection, etc.).
    private let pickerInputHandler: PickerInput

    /// Internal initializer for dependency injection (used in tests).
    /// - Parameters:
    ///   - textInputHandler: Handler for text input and permission prompts.
    ///   - pickerInputHandler: Handler for picker-specific input operations.
    init(textInputHandler: TextInputHandler, pickerInputHandler: PickerInput) {
        self.textInputHandler = textInputHandler
        self.pickerInputHandler = pickerInputHandler
    }
}


// MARK: - Init
public extension InteractivePicker {
    /// Initializes a new instance of `InteractivePicker`.
    init() {
        self.textInputHandler = DefaultInputHandler()
        self.pickerInputHandler = PickerInputAdapter()
    }
}


// MARK: - Input
public extension InteractivePicker {
    /// Prompts the user for input with the given prompt string.
    /// - Parameter prompt: The prompt message to display to the user.
    /// - Returns: The user's input as a String.
    func getInput(prompt: PickerPrompt) -> String {
        return textInputHandler.getInput(prompt.title)
    }

    /// Prompts the user for input with the given prompt string and requires input.
    /// - Parameter prompt: The prompt message to display to the user.
    /// - Throws: `SwiftPickerError.inputRequired` if the user does not provide any input.
    /// - Returns: The user's input as a String.
    func getRequiredInput(prompt: PickerPrompt) throws -> String {
        let input = getInput(prompt: prompt)
        if input.isEmpty {
            throw SwiftPickerError.inputRequired
        }
        return input
    }
}


// MARK: - Permission
public extension InteractivePicker {
    /// Prompts the user for permission with a yes/no question.
    /// - Parameter prompt: The prompt message to display to the user.
    /// - Returns: `true` if the user grants permission, `false` otherwise.
    func getPermission(prompt: PickerPrompt) -> Bool {
        return textInputHandler.getPermission(prompt.title)
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
public extension InteractivePicker {
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
public extension InteractivePicker {
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


// MARK: - ColumnSelection
public extension InteractivePicker {
    /// Displays multiple columns for navigation and selection.
    /// Supports horizontal navigation between columns (←→) and vertical navigation within columns (↑↓).
    /// Press Space to navigate into an item (loads children), Enter to select, Q to quit.
    /// - Parameters:
    ///   - columns: Array of columns to display. Each column contains a title and list of items.
    ///   - title: The title to display above the columns. Defaults to empty string.
    ///   - newScreen: Whether to use alternative screen mode. Defaults to true.
    ///   - onNavigate: Closure called when user presses Space on an item. Should return children items and column title, or nil if item has no children.
    /// - Returns: The selected item from the active column, or `nil` if the user quits.
    func columnSelection<Item: DisplayablePickerItem>(
        columns: [PickerColumn<Item>],
        title: some PickerPrompt = "",
        newScreen: Bool = true,
        onNavigate: ((Item) -> (items: [Item], title: String)?)? = nil
    ) -> Item? {
        let handler = SelectionHandlerFactory.makeColumnSelectionHandler(
            columns: columns,
            title: title.title,
            newScreen: newScreen,
            inputHandler: pickerInputHandler,
            onNavigate: onNavigate
        )

        return handler.captureUserInput()
    }

    /// Displays a dual-column layout with one selectable column and one static display column.
    /// User can navigate both columns with arrow keys but can only select items from the first column.
    /// The second column remains static and is for display/reference only.
    /// - Parameters:
    ///   - selectableItems: Items in the left column that can be selected with Enter.
    ///   - staticDisplayItems: Items in the right column for display only (cannot be selected).
    ///   - selectableTitle: Title for the selectable column.
    ///   - displayTitle: Title for the static display column.
    ///   - title: Main title to display above both columns. Defaults to empty string.
    ///   - newScreen: Whether to use alternative screen mode. Defaults to true.
    /// - Returns: The selected item from the selectable column, or `nil` if the user quits.
    func dualColumnSelection<Item: DisplayablePickerItem>(
        selectableItems: [Item],
        staticDisplayItems: [Item],
        selectableTitle: String,
        displayTitle: String,
        title: some PickerPrompt = "",
        newScreen: Bool = true
    ) -> Item? {
        let selectableColumn = PickerColumn(title: selectableTitle, items: selectableItems)
        let displayColumn = PickerColumn(title: displayTitle, items: staticDisplayItems)

        let handler = SelectionHandlerFactory.makeDualColumnSelectionHandler(
            selectableColumn: selectableColumn,
            displayColumn: displayColumn,
            title: title.title,
            newScreen: newScreen,
            inputHandler: pickerInputHandler
        )

        return handler.captureUserInput()
    }

    /// Displays a dual-column layout with multi-selection in the first column and a static display in the second.
    /// User can toggle multiple items in the left column with Space, and the right column remains static for reference.
    /// - Parameters:
    ///   - selectableItems: Items in the left column that can be multi-selected with Space and confirmed with Enter.
    ///   - staticDisplayItems: Items in the right column for display only (cannot be selected).
    ///   - selectableTitle: Title for the selectable column.
    ///   - displayTitle: Title for the static display column.
    ///   - title: Main title to display above both columns. Defaults to empty string.
    ///   - newScreen: Whether to use alternative screen mode. Defaults to true.
    /// - Returns: An array of selected items from the selectable column.
    func multiSelectionDualColumn<Item: DisplayablePickerItem>(
        selectableItems: [Item],
        staticDisplayItems: [Item],
        selectableTitle: String,
        displayTitle: String,
        title: some PickerPrompt = "",
        newScreen: Bool = true
    ) -> [Item] {
        let selectableColumn = PickerColumn(title: selectableTitle, items: selectableItems)
        let displayColumn = PickerColumn(title: displayTitle, items: staticDisplayItems)

        let handler = SelectionHandlerFactory.makeMultiSelectionDualColumnHandler(
            selectableColumn: selectableColumn,
            displayColumn: displayColumn,
            title: title.title,
            newScreen: newScreen,
            inputHandler: pickerInputHandler
        )

        return handler.captureMultiUserInput()
    }

    /// Displays a dual-column layout with multi-selection in the first column and a dynamic display in the second.
    /// The second column updates automatically based on which item is currently highlighted in the first column.
    /// - Parameters:
    ///   - selectableItems: Items in the left column that can be multi-selected with Space and confirmed with Enter.
    ///   - selectableTitle: Title for the selectable column.
    ///   - displayTitle: Title for the dynamic display column.
    ///   - title: Main title to display above both columns. Defaults to empty string.
    ///   - newScreen: Whether to use alternative screen mode. Defaults to true.
    ///   - onActiveItemChange: Closure that returns items to display in the second column based on the currently highlighted item in the first column.
    /// - Returns: An array of selected items from the selectable column.
    func dynamicMultiSelectionDualColumn<Item: DisplayablePickerItem>(
        selectableItems: [Item],
        selectableTitle: String,
        displayTitle: String,
        title: some PickerPrompt = "",
        newScreen: Bool = true,
        onActiveItemChange: @escaping (Item) -> [Item]
    ) -> [Item] {
        let handler = SelectionHandlerFactory.makeDynamicMultiSelectionDualColumnHandler(
            selectableItems: selectableItems,
            selectableTitle: selectableTitle,
            displayTitle: displayTitle,
            title: title.title,
            newScreen: newScreen,
            inputHandler: pickerInputHandler,
            onActiveItemChange: onActiveItemChange
        )

        return handler.captureMultiUserInput()
    }
}


// MARK: - Private Methods
private extension InteractivePicker {
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
        let handler = SelectionHandlerFactory.makeSingleSelectionHandler(info: info, newScreen: showNewScreen, inputHandler: pickerInputHandler)
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
        let handler = SelectionHandlerFactory.makeMultiSelectionHandler(info: info, newScreen: showNewScreen, inputHandler: pickerInputHandler)
        let selections = handler.captureUserInput()

        handler.endSelection()
        handler.printResults(selections.map({ $0.displayName }))

        return selections
    }
}


// MARK: - Legacy
/// Legacy struct name for backward compatibility. Use `InteractivePicker` instead.
@available(*, deprecated, renamed: "InteractivePicker", message: "Use InteractivePicker to avoid confusion with package name")
public typealias SwiftPicker = InteractivePicker
