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
    private let headerRenderer: PickerHeaderRenderer

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
        self.headerRenderer = PickerHeaderRenderer(inputHandler: inputHandler)
    }
}


// MARK: - Capture Input
extension ColumnSelectionHandler {
    /// Captures the user's input for column selection.
    /// - Returns: The selected item from the active column, or `nil` if the user quit.
    func captureUserInput() -> Item? {
        // Set up signal handlers to ensure terminal cleanup on interrupt
        SignalHandler.setupSignalHandlers { [inputHandler] in
            inputHandler.exitAlternativeScreen()
            inputHandler.enableNormalInput()
        }

        defer {
            SignalHandler.removeSignalHandlers()
        }

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

    /// Captures the user's input for multi-selection column selection.
    /// - Returns: An array of selected items from the active column.
    func captureMultiUserInput() -> [Item] {
        // Set up signal handlers to ensure terminal cleanup on interrupt
        SignalHandler.setupSignalHandlers { [inputHandler] in
            inputHandler.exitAlternativeScreen()
            inputHandler.enableNormalInput()
        }

        defer {
            SignalHandler.removeSignalHandlers()
        }

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
                            return state.activeColumn.selectedItems
                        }
                        // Otherwise, ignore the Enter key press
                    case .quit:
                        endSelection()
                        return []
                    case .space:
                        handleSpaceKeySelection()
                        renderColumns()
                    case .backspace:
                        // No action for backspace in multi-selection dual-column mode
                        continue
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

    /// Handles space key press to toggle selection in multi-selection mode.
    func handleSpaceKeySelection() {
        // Only toggle selection if the active column is selectable
        guard state.activeColumn.isSelectable else { return }

        var column = state.activeColumn
        column.toggleSelection()
        state.activeColumn = column
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
        let (rows, screenCols) = inputHandler.readScreenSize()

        // Render header with selected item
        headerRenderer.renderHeader(
            topLineText: state.topLineText,
            title: state.title,
            selectedItem: state.activeColumn.activeItem,
            screenWidth: screenCols,
            showScrollUpIndicator: false
        )
        inputHandler.write("\n")

        // Calculate visible columns based on screen size
        let maxVisibleColumns = calculateMaxVisibleColumns(screenWidth: screenCols)
        let columnsToRender = Array(state.columns.prefix(maxVisibleColumns))

        // Calculate footer space (always 2 rows for column-style footer)
        let footerRows = 2
        let maxRows = rows - 9 - (footerRows - 1)

        // Render each column (starting at row 6 to avoid overwriting breadcrumb title on row 4)
        for (columnIndex, column) in columnsToRender.enumerated() {
            let colX = calculateColumnXPosition(for: columnIndex)
            let isActiveColumn = columnIndex == state.activeColumnIndex
            let isLastColumn = columnIndex == columnsToRender.count - 1

            renderColumn(column, at: colX, row: 6, isActive: isActiveColumn, maxRows: maxRows, isLastColumn: isLastColumn, screenWidth: screenCols)
        }

        // Render dividers between columns (starting at row 5 for column titles)
        if columnsToRender.count > 1 {
            renderDividers(columnCount: columnsToRender.count, startRow: 5, maxRows: maxRows)
        }

        // Render separator line before footer
        let separatorRow = rows - 3 - footerRows
        renderSeparator(at: separatorRow, screenWidth: screenCols)

        // Render navigation hints (footer uses 1 or 2 rows depending on mode)
        let footerStartRow = separatorRow + 1
        renderFooter(at: footerStartRow)
    }

    /// Renders a single column.
    /// - Parameters:
    ///   - column: The column to render.
    ///   - colX: The X position (column) where the column should be rendered.
    ///   - row: The starting row for rendering items.
    ///   - isActive: Whether this is the currently active column.
    ///   - maxRows: Maximum number of rows to display.
    ///   - isLastColumn: Whether this is the last (rightmost) column.
    ///   - screenWidth: The width of the screen in characters.
    func renderColumn(_ column: PickerColumn<Item>, at colX: Int, row: Int, isActive: Bool, maxRows: Int, isLastColumn: Bool, screenWidth: Int) {
        // Calculate the effective column width
        // Last column uses remaining screen space, others use fixed columnWidth
        let effectiveColumnWidth: Int
        if isLastColumn {
            // Use remaining screen width minus a small margin
            effectiveColumnWidth = max(columnWidth, screenWidth - colX - 2)
        } else {
            effectiveColumnWidth = columnWidth
        }

        // Render column title
        inputHandler.moveTo(row - 1, colX)

        // Add "[View Only]" suffix for non-selectable columns
        let titleText = column.isSelectable ? column.title : "\(column.title) [View Only]"
        let truncatedTitle = truncate(titleText, maxWidth: effectiveColumnWidth - 2)

        // Use dimmed color for non-selectable columns, normal style for selectable
        let titleStyle: String
        if !column.isSelectable {
            titleStyle = truncatedTitle.foreColor(247)  // Brighter gray for non-selectable
        } else {
            titleStyle = isActive ? truncatedTitle.underline : truncatedTitle.foreColor(250)
        }
        inputHandler.write(titleStyle)

        // Render separator line under title
        inputHandler.moveTo(row, colX)
        let separatorLength = min(effectiveColumnWidth - 2, max(truncatedTitle.count, 10))
        let separator = String(repeating: "─", count: separatorLength)
        let separatorStyle = !column.isSelectable ? separator.foreColor(247) : separator.foreColor(242)
        inputHandler.write(separatorStyle)

        // Render column items (starting one row below separator to make room)
        let itemsToShow = min(column.items.count, maxRows)
        for (itemIndex, item) in column.items.prefix(itemsToShow).enumerated() {
            let itemRow = row + 1 + itemIndex
            inputHandler.moveTo(itemRow, colX)

            let isActiveItem = itemIndex == column.activeIndex
            // Reserve 2 characters for the indicator ("> " or "• " or "○ ")
            let maxDisplayWidth = effectiveColumnWidth - 2
            let truncatedName = truncate(item.displayName, maxWidth: maxDisplayWidth)

            // Check if this item is selected (for multi-selection mode)
            let isItemSelected = column.isSelected(at: itemIndex)

            // Non-selectable columns get dimmed styling with different indicator
            if !column.isSelectable {
                if isActiveItem && isActive {
                    // Active item in active non-selectable column - use hollow circle indicator
                    inputHandler.write("✧ ".foreColor(250) + truncatedName.foreColor(250))
                } else if isActiveItem {
                    // Active item in inactive non-selectable column
                    inputHandler.write("✧ ".foreColor(247) + truncatedName.foreColor(247))
                } else {
                    // Inactive item in non-selectable column
                    inputHandler.write("  " + truncatedName.foreColor(247))
                }
            } else {
                // Selectable columns use normal styling
                // In multi-selection mode, show checkboxes
                if state.isMultiSelection {
                    if isItemSelected {
                        // Selected item (checked)
                        let indicator = isActiveItem && isActive ? "☑ ".lightGreen : "☑ ".green
                        let textColor: UInt8 = isActiveItem && isActive ? 51 : 250
                        inputHandler.write(indicator + truncatedName.foreColor(textColor))
                    } else {
                        // Unselected item (unchecked)
                        let indicator = isActiveItem && isActive ? "☐ ".lightGreen : "☐ ".foreColor(240)
                        let textColor: UInt8 = isActiveItem && isActive ? 51 : 250
                        inputHandler.write(indicator + truncatedName.foreColor(textColor))
                    }
                } else {
                    // Single selection mode - use normal indicators
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
            }
        }

        // Show scroll indicators if there are more items
        if column.items.count > maxRows {
            inputHandler.moveTo(row + 1 + maxRows, colX)
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

    /// Renders the footer with navigation instructions in 3 columns.
    /// - Parameter row: The row position for the footer.
    func renderFooter(at row: Int) {
        renderColumnFooter(at: row)
    }

    /// Renders the footer with navigation instructions organized in 3 columns.
    /// - Parameter row: The row position for the footer.
    func renderColumnFooter(at row: Int) {
        let columnWidth = 30
        let col1X = 1
        let col2X = col1X + columnWidth
        let col3X = col2X + columnWidth

        if state.isMultiSelection {
            // Multi-selection mode footer
            // Column 1: Arrow key navigation
            inputHandler.moveTo(row, col1X)
            inputHandler.write("←→: switch columns")
            inputHandler.moveTo(row + 1, col1X)
            inputHandler.write("↑↓: navigate items")

            // Column 2: Space for toggle
            inputHandler.moveTo(row, col2X)
            if state.activeColumn.isSelectable {
                inputHandler.write("Space: toggle selection")
            } else {
                inputHandler.write("Space: (cannot select)")
            }
            inputHandler.moveTo(row + 1, col2X)
            inputHandler.write("") // Leave blank

            // Column 3: Enter and Quit
            inputHandler.moveTo(row, col3X)
            if state.activeColumn.isSelectable {
                let count = state.activeColumn.selectedIndices.count
                inputHandler.write("Enter: confirm (\(count) selected)")
            } else {
                inputHandler.write("Enter: (cannot select)")
            }
            inputHandler.moveTo(row + 1, col3X)
            inputHandler.write("Q: quit")
        } else {
            // Single selection mode footer
            // Column 1: Arrow key navigation
            inputHandler.moveTo(row, col1X)
            inputHandler.write("←→: switch columns")
            inputHandler.moveTo(row + 1, col1X)
            inputHandler.write("↑↓: navigate items")

            // Column 2: Space and Backspace
            inputHandler.moveTo(row, col2X)
            inputHandler.write("Space: open")
            inputHandler.moveTo(row + 1, col2X)
            inputHandler.write("Backspace: go back")

            // Column 3: Enter and Quit
            inputHandler.moveTo(row, col3X)
            if state.activeColumn.isSelectable {
                inputHandler.write("Enter: select")
            } else {
                inputHandler.write("Enter: (cannot select from this column)")
            }
            inputHandler.moveTo(row + 1, col3X)
            inputHandler.write("Q: quit")
        }
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
