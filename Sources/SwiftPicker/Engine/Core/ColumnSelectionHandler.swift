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

    /// Initializes a new column selection handler.
    /// - Parameters:
    ///   - state: The column selection state to manage.
    ///   - inputHandler: The input handler for reading user input and controlling the terminal.
    ///   - columnWidth: The width of each column in characters. Defaults to 30.
    ///   - columnSpacing: The spacing between columns in characters. Defaults to 4.
    init(state: ColumnSelectionState<Item>, inputHandler: PickerInput, columnWidth: Int = 30, columnSpacing: Int = 4) {
        self.state = state
        self.inputHandler = inputHandler
        self.columnWidth = columnWidth
        self.columnSpacing = columnSpacing
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
                        endSelection()
                        return state.activeColumn.activeItem
                    case .quit:
                        endSelection()
                        return nil
                    case .space:
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
    /// - Parameter delta: The number of columns to move (-1 for left, 1 for right).
    func moveHorizontal(delta: Int) {
        let newColumnIndex = state.activeColumnIndex + delta

        if newColumnIndex >= 0 && newColumnIndex < state.columns.count {
            state.activeColumnIndex = newColumnIndex
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

        // Render navigation hints
        renderFooter(at: rows - 2)
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
        let titleStyle = isActive ? column.title.underline : column.title.foreColor(250)
        inputHandler.write(titleStyle)

        // Render column items (limited by maxRows)
        let itemsToShow = min(column.items.count, maxRows)
        for (itemIndex, item) in column.items.prefix(itemsToShow).enumerated() {
            let itemRow = row + itemIndex
            inputHandler.moveTo(itemRow, colX)

            let isActiveItem = itemIndex == column.activeIndex

            if isActiveItem && isActive {
                // Active column, active item
                inputHandler.write("> ".lightGreen + item.displayName)
            } else if isActiveItem {
                // Inactive column, active item
                inputHandler.write("• ".yellow + item.displayName.foreColor(250))
            } else {
                // Inactive item
                inputHandler.write("  " + item.displayName.foreColor(250))
            }
        }

        // Show scroll indicators if there are more items
        if column.items.count > maxRows {
            inputHandler.moveTo(row + maxRows, colX)
            inputHandler.write("⋮".foreColor(250))
        }
    }

    /// Renders the footer with navigation instructions.
    /// - Parameter row: The row position for the footer.
    func renderFooter(at row: Int) {
        inputHandler.moveTo(row, 1)
        inputHandler.write(state.bottomLineText)
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

    /// Centers text within the specified width.
    /// - Parameters:
    ///   - text: The text to center.
    ///   - width: The width within which to center the text.
    /// - Returns: The centered text with padding.
    func centerText(_ text: String, inWidth width: Int) -> String {
        let textLength = text.count
        let spaces = (width - textLength) / 2
        let padding = String(repeating: " ", count: max(0, spaces))

        return padding + text
    }
}
