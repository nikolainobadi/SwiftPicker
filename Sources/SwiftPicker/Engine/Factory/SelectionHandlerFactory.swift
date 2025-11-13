//
//  SelectionHandlerFactory.swift
//
//
//  Created by Nikolai Nobadi on 5/16/24.
//

/// An enumeration that composes various handlers for SwiftPicker.
/// Provides methods to create single and multi-selection handlers.
enum SelectionHandlerFactory {
    /// The input handler for reading user input and controlling the terminal.
    static var inputHandler: PickerInput = PickerInputAdapter()
}

// MARK: - Composer
extension SelectionHandlerFactory {
    /// Creates a single selection handler with the provided information.
    /// - Parameters:
    ///   - info: The PickerInfo object containing the title and items.
    ///   - newScreen: A Boolean value indicating whether to show a new screen.
    /// - Returns: A SingleSelectionHandler instance.
    static func makeSingleSelectionHandler<Item: DisplayablePickerItem>(info: PickerInfo<Item>, newScreen: Bool) -> SingleSelectionHandler<Item> {
        let state = makeState(info: info, newScreen: newScreen, isSingleSelection: true, inputHandler: inputHandler)
        return .init(state: state, inputHandler: inputHandler)
    }
    
    /// Creates a multi-selection handler with the provided information.
    /// - Parameters:
    ///   - info: The PickerInfo object containing the title and items.
    ///   - newScreen: A Boolean value indicating whether to show a new screen.
    /// - Returns: A MultiSelectionHandler instance.
    static func makeMultiSelectionHandler<Item: DisplayablePickerItem>(info: PickerInfo<Item>, newScreen: Bool) -> MultiSelectionHandler<Item> {
        let state = makeState(info: info, newScreen: newScreen, isSingleSelection: false, inputHandler: inputHandler)
        return .init(state: state, inputHandler: inputHandler)
    }
    
    /// Creates a single selection handler with the provided information and custom input handler.
    /// - Parameters:
    ///   - info: The PickerInfo object containing the title and items.
    ///   - newScreen: A Boolean value indicating whether to show a new screen.
    ///   - inputHandler: Custom input handler to use instead of the default.
    /// - Returns: A SingleSelectionHandler instance.
    static func makeSingleSelectionHandler<Item: DisplayablePickerItem>(info: PickerInfo<Item>, newScreen: Bool, inputHandler: PickerInput) -> SingleSelectionHandler<Item> {
        let state = makeState(info: info, newScreen: newScreen, isSingleSelection: true, inputHandler: inputHandler)
        return .init(state: state, inputHandler: inputHandler)
    }
    
    /// Creates a multi-selection handler with the provided information and custom input handler.
    /// - Parameters:
    ///   - info: The PickerInfo object containing the title and items.
    ///   - newScreen: A Boolean value indicating whether to show a new screen.
    ///   - inputHandler: Custom input handler to use instead of the default.
    /// - Returns: A MultiSelectionHandler instance.
    static func makeMultiSelectionHandler<Item: DisplayablePickerItem>(info: PickerInfo<Item>, newScreen: Bool, inputHandler: PickerInput) -> MultiSelectionHandler<Item> {
        let state = makeState(info: info, newScreen: newScreen, isSingleSelection: false, inputHandler: inputHandler)
        return .init(state: state, inputHandler: inputHandler)
    }

    /// Creates a column selection handler with the default input handler.
    /// - Parameters:
    ///   - columns: The columns to display.
    ///   - title: The title to display above the columns.
    ///   - newScreen: A Boolean value indicating whether to show a new screen.
    ///   - onNavigate: Closure called when user presses Space on an item. Should return children items and column title, or nil if item has no children.
    /// - Returns: A ColumnSelectionHandler instance.
    static func makeColumnSelectionHandler<Item: DisplayablePickerItem>(
        columns: [PickerColumn<Item>],
        title: String,
        newScreen: Bool,
        onNavigate: ((Item) -> (items: [Item], title: String)?)? = nil
    ) -> ColumnSelectionHandler<Item> {
        return makeColumnSelectionHandler(columns: columns, title: title, newScreen: newScreen, inputHandler: inputHandler, onNavigate: onNavigate)
    }

    /// Creates a column selection handler with a custom input handler.
    /// - Parameters:
    ///   - columns: The columns to display.
    ///   - title: The title to display above the columns.
    ///   - newScreen: A Boolean value indicating whether to show a new screen.
    ///   - inputHandler: Custom input handler to use instead of the default.
    ///   - onNavigate: Closure called when user presses Space on an item. Should return children items and column title, or nil if item has no children.
    /// - Returns: A ColumnSelectionHandler instance.
    static func makeColumnSelectionHandler<Item: DisplayablePickerItem>(
        columns: [PickerColumn<Item>],
        title: String,
        newScreen: Bool,
        inputHandler: PickerInput,
        onNavigate: ((Item) -> (items: [Item], title: String)?)? = nil
    ) -> ColumnSelectionHandler<Item> {
        configureScreen(newScreen, inputHandler: inputHandler)
        let topLine = inputHandler.readCursorPos().row + PickerPadding.top

        let state = ColumnSelectionState(
            columns: columns,
            activeColumnIndex: columns.count - 1,
            title: title,
            topLine: topLine
        )

        return .init(state: state, inputHandler: inputHandler, onNavigate: onNavigate)
    }

    /// Creates a dual-column selection handler with the default input handler.
    /// The first column is selectable (Enter to select), the second column is static display only.
    /// - Parameters:
    ///   - selectableColumn: The left column containing items that can be selected.
    ///   - displayColumn: The right column containing static display items.
    ///   - title: The title to display above the columns.
    ///   - newScreen: A Boolean value indicating whether to show a new screen.
    /// - Returns: A ColumnSelectionHandler instance configured for dual-column selection.
    static func makeDualColumnSelectionHandler<Item: DisplayablePickerItem>(
        selectableColumn: PickerColumn<Item>,
        displayColumn: PickerColumn<Item>,
        title: String,
        newScreen: Bool
    ) -> ColumnSelectionHandler<Item> {
        return makeDualColumnSelectionHandler(
            selectableColumn: selectableColumn,
            displayColumn: displayColumn,
            title: title,
            newScreen: newScreen,
            inputHandler: inputHandler
        )
    }

    /// Creates a dual-column selection handler with a custom input handler.
    /// The first column is selectable (Enter to select), the second column is static display only.
    /// - Parameters:
    ///   - selectableColumn: The left column containing items that can be selected.
    ///   - displayColumn: The right column containing static display items.
    ///   - title: The title to display above the columns.
    ///   - newScreen: A Boolean value indicating whether to show a new screen.
    ///   - inputHandler: Custom input handler to use instead of the default.
    /// - Returns: A ColumnSelectionHandler instance configured for dual-column selection.
    static func makeDualColumnSelectionHandler<Item: DisplayablePickerItem>(
        selectableColumn: PickerColumn<Item>,
        displayColumn: PickerColumn<Item>,
        title: String,
        newScreen: Bool,
        inputHandler: PickerInput
    ) -> ColumnSelectionHandler<Item> {
        // Ensure first column is selectable and second is not
        let firstColumn = PickerColumn(
            title: selectableColumn.title,
            items: selectableColumn.items,
            activeIndex: selectableColumn.activeIndex,
            isSelectable: true
        )

        let secondColumn = PickerColumn(
            title: displayColumn.title,
            items: displayColumn.items,
            activeIndex: displayColumn.activeIndex,
            isSelectable: false
        )

        configureScreen(newScreen, inputHandler: inputHandler)
        let topLine = inputHandler.readCursorPos().row + PickerPadding.top

        let state = ColumnSelectionState(
            columns: [firstColumn, secondColumn],
            activeColumnIndex: 0,  // Start with first column active
            title: title,
            topLine: topLine
        )

        return .init(state: state, inputHandler: inputHandler, onNavigate: nil)
    }

    /// Creates a multi-selection dual-column handler with the default input handler.
    /// The first column supports multi-selection (Space to toggle, Enter to confirm), the second column is static display only.
    /// - Parameters:
    ///   - selectableColumn: The left column containing items that can be multi-selected.
    ///   - displayColumn: The right column containing static display items.
    ///   - title: The title to display above the columns.
    ///   - newScreen: A Boolean value indicating whether to show a new screen.
    /// - Returns: A ColumnSelectionHandler instance configured for multi-selection dual-column.
    static func makeMultiSelectionDualColumnHandler<Item: DisplayablePickerItem>(
        selectableColumn: PickerColumn<Item>,
        displayColumn: PickerColumn<Item>,
        title: String,
        newScreen: Bool
    ) -> ColumnSelectionHandler<Item> {
        return makeMultiSelectionDualColumnHandler(
            selectableColumn: selectableColumn,
            displayColumn: displayColumn,
            title: title,
            newScreen: newScreen,
            inputHandler: inputHandler
        )
    }

    /// Creates a multi-selection dual-column handler with a custom input handler.
    /// The first column supports multi-selection (Space to toggle, Enter to confirm), the second column is static display only.
    /// - Parameters:
    ///   - selectableColumn: The left column containing items that can be multi-selected.
    ///   - displayColumn: The right column containing static display items.
    ///   - title: The title to display above the columns.
    ///   - newScreen: A Boolean value indicating whether to show a new screen.
    ///   - inputHandler: Custom input handler to use instead of the default.
    /// - Returns: A ColumnSelectionHandler instance configured for multi-selection dual-column.
    static func makeMultiSelectionDualColumnHandler<Item: DisplayablePickerItem>(
        selectableColumn: PickerColumn<Item>,
        displayColumn: PickerColumn<Item>,
        title: String,
        newScreen: Bool,
        inputHandler: PickerInput
    ) -> ColumnSelectionHandler<Item> {
        // Ensure first column is selectable and second is not
        let firstColumn = PickerColumn(
            title: selectableColumn.title,
            items: selectableColumn.items,
            activeIndex: selectableColumn.activeIndex,
            isSelectable: true
        )

        let secondColumn = PickerColumn(
            title: displayColumn.title,
            items: displayColumn.items,
            activeIndex: displayColumn.activeIndex,
            isSelectable: false
        )

        configureScreen(newScreen, inputHandler: inputHandler)
        let topLine = inputHandler.readCursorPos().row + PickerPadding.top

        let state = ColumnSelectionState(
            columns: [firstColumn, secondColumn],
            activeColumnIndex: 0,  // Start with first column active
            title: title,
            topLine: topLine,
            isMultiSelection: true  // Enable multi-selection mode
        )

        return .init(state: state, inputHandler: inputHandler, onNavigate: nil)
    }
}

// MARK: - Private Methods
private extension SelectionHandlerFactory {
    /// Creates a selection state with the provided information.
    /// - Parameters:
    ///   - info: The PickerInfo object containing the title and items.
    ///   - newScreen: A Boolean value indicating whether to show a new screen.
    ///   - isSingleSelection: A Boolean value indicating whether the selection mode is single selection.
    ///   - inputHandler: The input handler to use for screen configuration and cursor positioning.
    /// - Returns: A SelectionState instance.
    static func makeState<Item: DisplayablePickerItem>(info: PickerInfo<Item>, newScreen: Bool, isSingleSelection: Bool, inputHandler: PickerInput) -> SelectionState<Item> {
        configureScreen(newScreen, inputHandler: inputHandler)
        let topLine = inputHandler.readCursorPos().row + PickerPadding.top
        let options = makeOptions(items: info.items, topLine: topLine)
        return .init(options: options, topLine: topLine, title: info.title, isSingleSelection: isSingleSelection)
    }
    
    /// Configures the screen for selection.
    /// - Parameters:
    ///   - newScreen: A Boolean value indicating whether to show a new screen.
    ///   - inputHandler: The input handler to use for screen configuration.
    static func configureScreen(_ newScreen: Bool, inputHandler: PickerInput) {
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
