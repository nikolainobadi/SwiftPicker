//
//  ColumnSelectionHandler.swift
//
//
//  Created by Nikolai Nobadi on 11/8/25.
//

/// A class for handling multi-column selection logic in InteractivePicker.
/// Supports horizontal navigation between columns and vertical navigation within columns.
final class ColumnSelectionHandler<Item: DisplayablePickerItem> {
    private let state: ColumnSelectionState<Item>
    private let inputHandler: PickerInput
    private let columnWidth: Int
    private let columnSpacing: Int
    private let onNavigate: ((Item) -> (items: [Item], title: String)?)?

    /// Initializes a new column selection handler.
    /// - Parameters:
    ///   - state: The column selection state to manage.
    ///   - inputHandler: The input handler for reading user input and controlling the terminal.
    ///   - columnWidth: The width of each column in characters. Defaults to 30.
    ///   - columnSpacing: The spacing between columns in characters. Defaults to 4.
    ///   - onNavigate: Closure called when user presses Space on an item. Should return children items and column title, or nil if item has no children.
    init(state: ColumnSelectionState<Item>, inputHandler: PickerInput, columnWidth: Int = 30, columnSpacing: Int = 4, onNavigate: ((Item) -> (items: [Item], title: String)?)? = nil) {
        self.state = state
        self.inputHandler = inputHandler
        self.columnWidth = columnWidth
        self.columnSpacing = columnSpacing
        self.onNavigate = onNavigate
    }
}


// MARK: - Capture Input
extension ColumnSelectionHandler {
    /// Captures the user's input for column selection.
    /// - Returns: The selected item from the active column, or `nil` if the user quit.
    func captureUserInput() -> Item? {
        renderColumns()

        while true {
            inputHandler.clearBuffer()
            if inputHandler.keyPressed() {
                if let specialChar = inputHandler.readSpecialChar() {
                    switch specialChar {
                    case .enter:
                        // Only allow selection if the active column is selectable
                        if state.activeColumn.isSelectable {
                            endSelection()
                            return state.activeColumn.activeItem
                        }
                        // Otherwise, ignore the Enter key press
                    case .quit:
                        endSelection()
                        return nil
                    case .space:
                        handleSpaceKeyNavigation()
                        renderColumns()
                    case .backspace:
                        handleBackNavigation()
                        renderColumns()
                    }
                }

                handleNavigation()
                renderColumns()
            }
        }
    }
}


// MARK: - Navigation
private extension ColumnSelectionHandler {
    /// Handles user navigation input (arrow keys).
    func handleNavigation() {
        guard let direction = inputHandler.readDirectionKey() else { return }

        switch direction {
        case .up:
            moveVertical(delta: -1)
        case .down:
            moveVertical(delta: 1)
        case .left:
            moveHorizontal(delta: -1)
        case .right:
            moveHorizontal(delta: 1)
        }
    }

    /// Handles space key press to navigate into selected item's children.
    func handleSpaceKeyNavigation() {
        guard let onNavigate = onNavigate,
              let activeItem = state.activeColumn.activeItem,
              let result = onNavigate(activeItem) else {
            return
        }

        addChildColumn(items: result.items, title: result.title)
    }

    /// Handles backspace key press to navigate back to parent level.
    /// Removes the current column from the stack and adjusts the visible window.
    func handleBackNavigation() {
        // Can't go back if we only have one column (already at root)
        guard state.navigationStack.count > 1 else { return }

        // Remove the last column from the stack
        state.navigationStack.removeLast()

        // Adjust visible window to show last 2 columns
        if state.navigationStack.count > 2 {
            state.visibleStartIndex = state.navigationStack.count - 2
            state.activeColumnIndex = 1  // Stay on the rightmost visible column
        } else {
            state.visibleStartIndex = 0
            state.activeColumnIndex = state.navigationStack.count - 1
        }

        // Update breadcrumb to reflect new navigation path
        updateBreadcrumb()
    }

    /// Adds a new column with child items to the right of the active column.
    /// Implements a 2-column sliding window: adds to navigation stack and shifts visible window.
    /// Updates the breadcrumb title to reflect the new navigation path.
    /// - Parameters:
    ///   - items: The child items to display in the new column.
    ///   - title: The title for the new column.
    func addChildColumn(items: [Item], title: String) {
        let newColumn = PickerColumn(title: title, items: items, activeIndex: 0)
        let stackInsertIndex = state.visibleStartIndex + state.activeColumnIndex + 1

        // Remove any columns in the stack after where we're inserting
        if stackInsertIndex < state.navigationStack.count {
            state.navigationStack.removeSubrange(stackInsertIndex...)
        }

        // Add the new column to the navigation stack
        state.navigationStack.append(newColumn)

        // Implement 2-column sliding window: shift visible window to show last 2 columns
        if state.navigationStack.count > 2 {
            state.visibleStartIndex = state.navigationStack.count - 2
            state.activeColumnIndex = 1  // Stay on the rightmost (newly added) column
        } else {
            state.visibleStartIndex = 0
            state.activeColumnIndex = state.navigationStack.count - 1
        }

        // Update breadcrumb to reflect new navigation path
        updateBreadcrumb()
    }

    /// Moves the active item within the current column.
    /// - Parameter delta: The number of positions to move (-1 for up, 1 for down).
    func moveVertical(delta: Int) {
        var column = state.activeColumn
        let newIndex = column.activeIndex + delta

        if newIndex >= 0 && newIndex < column.items.count {
            column.activeIndex = newIndex
            state.activeColumn = column
        }
    }

    /// Moves between columns.
    /// Updates the breadcrumb title to reflect the active column context.
    /// - Parameter delta: The number of columns to move (-1 for left, 1 for right).
    func moveHorizontal(delta: Int) {
        let newColumnIndex = state.activeColumnIndex + delta

        if newColumnIndex >= 0 && newColumnIndex < state.columns.count {
            state.activeColumnIndex = newColumnIndex
            // Update breadcrumb to show path up to active column
            updateBreadcrumb()
        }
    }
}


// MARK: - Rendering
private extension ColumnSelectionHandler {
    /// Renders all columns to the terminal.
    func renderColumns() {
        inputHandler.clearScreen()
        inputHandler.moveToHome()

        let (rows, screenCols) = inputHandler.readScreenSize()

        // Render title
        inputHandler.write(centerText(state.topLineText, inWidth: screenCols))
        inputHandler.write("\n\n")
        inputHandler.write(state.title)
        inputHandler.write("\n\n")

        // Calculate visible columns based on screen size
        let maxVisibleColumns = calculateMaxVisibleColumns(screenWidth: screenCols)
        let columnsToRender = Array(state.columns.prefix(maxVisibleColumns))

        // Render each column
        for (columnIndex, column) in columnsToRender.enumerated() {
            let colX = calculateColumnXPosition(for: columnIndex)
            let isActiveColumn = columnIndex == state.activeColumnIndex

            renderColumn(column, at: colX, row: 5, isActive: isActiveColumn, maxRows: rows - 8)
        }

        // Render dividers between columns
        if columnsToRender.count > 1 {
            renderDividers(columnCount: columnsToRender.count, startRow: 4, maxRows: rows - 8)
        }

        // Render separator line before footer
        renderSeparator(at: rows - 4, screenWidth: screenCols)

        // Render navigation hints
        renderFooter(at: rows - 3)

        // Render currently selected item name
        renderSelectedItemName(at: rows - 1, screenWidth: screenCols)
    }

    /// Renders a single column.
    /// - Parameters:
    ///   - column: The column to render.
    ///   - colX: The X position (column) where the column should be rendered.
    ///   - row: The starting row for rendering items.
    ///   - isActive: Whether this is the currently active column.
    ///   - maxRows: Maximum number of rows to display.
    func renderColumn(_ column: PickerColumn<Item>, at colX: Int, row: Int, isActive: Bool, maxRows: Int) {
        // Render column title
        inputHandler.moveTo(row - 1, colX)

        // Add "[View Only]" suffix for non-selectable columns
        let titleText = column.isSelectable ? column.title : "\(column.title) [View Only]"
        let truncatedTitle = truncate(titleText, maxWidth: columnWidth - 2)

        // Use dimmed color for non-selectable columns, normal style for selectable
        let titleStyle: String
        if !column.isSelectable {
            titleStyle = truncatedTitle.foreColor(240)  // Dimmed gray
        } else {
            titleStyle = isActive ? truncatedTitle.underline : truncatedTitle.foreColor(250)
        }
        inputHandler.write(titleStyle)

        // Render column items (limited by maxRows)
        let itemsToShow = min(column.items.count, maxRows)
        for (itemIndex, item) in column.items.prefix(itemsToShow).enumerated() {
            let itemRow = row + itemIndex
            inputHandler.moveTo(itemRow, colX)

            let isActiveItem = itemIndex == column.activeIndex
            // Reserve 2 characters for the indicator ("> " or "• ")
            let maxDisplayWidth = columnWidth - 2
            let truncatedName = truncate(item.displayName, maxWidth: maxDisplayWidth)

            if isActiveItem && isActive {
                // Active column, active item
                inputHandler.write("> ".lightGreen + truncatedName.foreColor(51))
            } else if isActiveItem {
                // Inactive column, active item
                inputHandler.write("• ".yellow + truncatedName.foreColor(250))
            } else {
                // Inactive item
                inputHandler.write("  " + truncatedName.foreColor(250))
            }
        }

        // Show scroll indicators if there are more items
        if column.items.count > maxRows {
            inputHandler.moveTo(row + maxRows, colX)
            inputHandler.write("⋮".foreColor(250))
        }
    }

    /// Renders vertical dividers between columns.
    /// - Parameters:
    ///   - columnCount: The number of columns being rendered.
    ///   - startRow: The starting row for the divider.
    ///   - maxRows: The maximum number of rows to draw the divider.
    func renderDividers(columnCount: Int, startRow: Int, maxRows: Int) {
        let dividerChar = "│"

        for columnIndex in 0..<(columnCount - 1) {
            // Calculate divider position between current and next column
            let firstColX = calculateColumnXPosition(for: columnIndex)
            let dividerX = firstColX + columnWidth + 1

            // Draw vertical line from title row to bottom of items
            for row in startRow...(startRow + maxRows + 1) {
                inputHandler.moveTo(row, dividerX)
                inputHandler.write(dividerChar.foreColor(240))
            }
        }
    }

    /// Renders a horizontal separator line.
    /// - Parameters:
    ///   - row: The row position for the separator.
    ///   - screenWidth: The width of the screen.
    func renderSeparator(at row: Int, screenWidth: Int) {
        inputHandler.moveTo(row, 1)
        let separator = String(repeating: "─", count: screenWidth - 2)
        inputHandler.write(separator.foreColor(240))
    }

    /// Renders the footer with navigation instructions.
    /// - Parameter row: The row position for the footer.
    func renderFooter(at row: Int) {
        inputHandler.moveTo(row, 1)

        let footerText: String
        if onNavigate != nil {
            // Column navigation mode with dynamic children
            if state.activeColumn.isSelectable {
                footerText = "Use ←→ to switch columns, ↑↓ to navigate • Space to open • Backspace to go back • Enter to select • Q to quit"
            } else {
                footerText = "Use ←→ to switch columns, ↑↓ to navigate • Space to open • Backspace to go back • Q to quit (cannot select from this column)"
            }
        } else {
            footerText = state.bottomLineText
        }

        inputHandler.write(footerText)
    }

    /// Renders the currently selected item's full name.
    /// - Parameters:
    ///   - row: The row position for the selected item name.
    ///   - screenWidth: The width of the screen for centering.
    func renderSelectedItemName(at row: Int, screenWidth: Int) {
        guard let selectedItem = state.activeColumn.activeItem else { return }

        inputHandler.moveTo(row, 1)

        let itemName = selectedItem.displayName

        // Truncate if too long for screen width
        let maxWidth = screenWidth - 2
        let finalText = itemName.count > maxWidth
            ? truncate(itemName, maxWidth: maxWidth)
            : itemName

        // Center and display in cyan color
        let centeredText = centerText(finalText, inWidth: screenWidth)
        inputHandler.write(centeredText.foreColor(51))  // Cyan color
    }

    /// Centers text within the specified width.
    /// - Parameters:
    ///   - text: The text to center.
    ///   - width: The width within which to center the text.
    /// - Returns: The centered text with padding.
    func centerText(_ text: String, inWidth width: Int) -> String {
        PickerTextFormatter.centerText(text, inWidth: width)
    }

    /// Truncates text to fit within the specified width, adding ellipsis if needed.
    /// - Parameters:
    ///   - text: The text to truncate.
    ///   - maxWidth: The maximum width allowed.
    /// - Returns: The truncated text with ellipsis if it was truncated.
    func truncate(_ text: String, maxWidth: Int) -> String {
        PickerTextFormatter.truncate(text, maxWidth: maxWidth)
    }

    /// Ends the selection process and restores terminal state.
    func endSelection() {
        inputHandler.exitAlternativeScreen()
        inputHandler.enableNormalInput()
    }
}


// MARK: - Helper Methods
private extension ColumnSelectionHandler {
    /// Calculates the maximum number of columns that can fit on the screen.
    /// - Parameter screenWidth: The width of the screen in characters.
    /// - Returns: The maximum number of columns that can be displayed.
    func calculateMaxVisibleColumns(screenWidth: Int) -> Int {
        let totalColumnWidth = columnWidth + columnSpacing
        return max(1, screenWidth / totalColumnWidth)
    }

    /// Calculates the X position for a column.
    /// - Parameter columnIndex: The index of the column.
    /// - Returns: The X position (column number) for rendering.
    func calculateColumnXPosition(for columnIndex: Int) -> Int {
        return 1 + (columnIndex * (columnWidth + columnSpacing))
    }

    /// Builds a breadcrumb trail from the column titles up to and including the active column.
    /// Uses the full navigation stack to show complete path.
    /// - Returns: A breadcrumb string in the format "Column1 > Column2 > Column3"
    func buildBreadcrumb() -> String {
        guard !state.navigationStack.isEmpty else { return "" }

        // Include columns from start of stack up to and including the active column
        let activeStackIndex = state.visibleStartIndex + state.activeColumnIndex
        let endIndex = min(activeStackIndex + 1, state.navigationStack.count)
        let relevantColumns = state.navigationStack.prefix(endIndex)
        let titles = relevantColumns.map { $0.title }
        return titles.joined(separator: " > ")
    }

    /// Updates the state title to reflect the current breadcrumb trail.
    func updateBreadcrumb() {
        state.title = buildBreadcrumb()
    }
}
