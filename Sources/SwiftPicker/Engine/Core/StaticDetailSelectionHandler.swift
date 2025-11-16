//
//  StaticDetailSelectionHandler.swift
//
//
//  Created by Nikolai Nobadi on 11/16/25.
//

/// A class for handling static detail column selection logic in InteractivePicker.
/// Displays selectable items in the first column and static instructions in the second column.
final class StaticDetailSelectionHandler<Item: DisplayablePickerItem> {
    private let state: StaticDetailColumnState<Item>
    private let inputHandler: PickerInput
    private let columnWidth: Int
    private let columnSpacing: Int
    private let headerRenderer: PickerHeaderRenderer

    /// Initializes a new static detail selection handler.
    /// - Parameters:
    ///   - state: The static detail column state to manage.
    ///   - inputHandler: The input handler for reading user input and controlling the terminal.
    ///   - columnWidth: The width of each column in characters. Defaults to 30.
    ///   - columnSpacing: The spacing between columns in characters. Defaults to 4.
    init(state: StaticDetailColumnState<Item>, inputHandler: PickerInput, columnWidth: Int = 30, columnSpacing: Int = 4) {
        self.state = state
        self.inputHandler = inputHandler
        self.columnWidth = columnWidth
        self.columnSpacing = columnSpacing
        self.headerRenderer = PickerHeaderRenderer(inputHandler: inputHandler)
    }
}


// MARK: - Capture Input
extension StaticDetailSelectionHandler {
    /// Captures the user's input for single selection.
    /// - Returns: The selected item from the selectable column, or `nil` if the user quit.
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
                        // Only allow selection from the selectable column
                        if state.activeColumnIndex == 0 {
                            endSelection()
                            return state.activeItem
                        }
                        // Ignore Enter in instructions column
                    case .quit:
                        endSelection()
                        return nil
                    case .space, .backspace:
                        // No action for space or backspace in static detail mode
                        continue
                    }
                }

                handleNavigation()
                renderColumns()
            }
        }
    }

    /// Captures the user's input for multi-selection.
    /// - Returns: An array of selected items from the selectable column.
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
                        // Only allow confirmation from the selectable column
                        if state.activeColumnIndex == 0 {
                            endSelection()
                            return state.selectedItems
                        }
                        // Ignore Enter in instructions column
                    case .quit:
                        endSelection()
                        return []
                    case .space:
                        handleSpaceKeySelection()
                        renderColumns()
                    case .backspace:
                        // No action for backspace in static detail mode
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
private extension StaticDetailSelectionHandler {
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

    /// Handles space key press to toggle selection in multi-selection mode.
    func handleSpaceKeySelection() {
        // Only toggle selection in the selectable column
        guard state.activeColumnIndex == 0 else { return }
        state.toggleSelection()
    }

    /// Moves the active item within the selectable column.
    /// - Parameter delta: The number of positions to move (-1 for up, 1 for down).
    func moveVertical(delta: Int) {
        // Only allow vertical movement in the selectable column
        guard state.activeColumnIndex == 0 else { return }

        let newIndex = state.activeIndex + delta
        if newIndex >= 0 && newIndex < state.selectableItems.count {
            state.activeIndex = newIndex
        }
    }

    /// Moves between columns (selectable and instructions).
    /// - Parameter delta: The number of columns to move (-1 for left, 1 for right).
    func moveHorizontal(delta: Int) {
        let newColumnIndex = state.activeColumnIndex + delta

        // Only allow moving between columns 0 and 1
        if newColumnIndex >= 0 && newColumnIndex < 2 {
            state.activeColumnIndex = newColumnIndex
        }
    }
}


// MARK: - Rendering
private extension StaticDetailSelectionHandler {
    /// Renders both columns to the terminal.
    func renderColumns() {
        let (rows, screenCols) = inputHandler.readScreenSize()

        // Render header with selected item
        headerRenderer.renderHeader(
            topLineText: state.topLineText,
            title: state.title,
            selectedItem: state.activeItem,
            screenWidth: screenCols,
            showScrollUpIndicator: false
        )
        inputHandler.write("\n")

        // Calculate footer space (always 2 rows for column-style footer)
        let footerRows = 2
        let maxRows = rows - 9 - (footerRows - 1)

        // Render selectable column (starting at row 6)
        let selectableColX = 1
        renderSelectableColumn(at: selectableColX, row: 6, maxRows: maxRows, screenWidth: screenCols)

        // Render instructions column
        let instructionsColX = selectableColX + columnWidth + columnSpacing
        renderInstructionsColumn(at: instructionsColX, row: 6, maxRows: maxRows, screenWidth: screenCols)

        // Render divider between columns (starting at row 5 for column titles)
        renderDivider(startRow: 5, maxRows: maxRows)

        // Render separator line before footer
        let separatorRow = rows - 3 - footerRows
        renderSeparator(at: separatorRow, screenWidth: screenCols)

        // Render navigation hints
        let footerStartRow = separatorRow + 1
        renderFooter(at: footerStartRow)
    }

    /// Renders the selectable column.
    /// - Parameters:
    ///   - colX: The X position (column) where the column should be rendered.
    ///   - row: The starting row for rendering items.
    ///   - maxRows: Maximum number of rows to display.
    ///   - screenWidth: The width of the screen in characters.
    func renderSelectableColumn(at colX: Int, row: Int, maxRows: Int, screenWidth: Int) {
        let isActive = state.activeColumnIndex == 0

        // Render column title
        inputHandler.moveTo(row - 1, colX)
        let truncatedTitle = truncate(state.selectableTitle, maxWidth: columnWidth - 2)
        let titleStyle = isActive ? truncatedTitle.underline : truncatedTitle.foreColor(250)
        inputHandler.write(titleStyle)

        // Render separator line under title
        inputHandler.moveTo(row, colX)
        let separatorLength = min(columnWidth - 2, max(truncatedTitle.count, 10))
        let separator = String(repeating: "─", count: separatorLength)
        inputHandler.write(separator.foreColor(242))

        // Render items (starting one row below separator)
        let itemsToShow = min(state.selectableItems.count, maxRows)
        for (itemIndex, item) in state.selectableItems.prefix(itemsToShow).enumerated() {
            let itemRow = row + 1 + itemIndex
            inputHandler.moveTo(itemRow, colX)

            let isActiveItem = itemIndex == state.activeIndex
            // Reserve 2 characters for the indicator
            let maxDisplayWidth = columnWidth - 2
            let truncatedName = truncate(item.displayName, maxWidth: maxDisplayWidth)

            // Check if this item is selected (for multi-selection mode)
            let isItemSelected = state.isSelected(at: itemIndex)

            // Render based on selection mode
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
                // Single selection mode
                if isActiveItem && isActive {
                    inputHandler.write("> ".lightGreen + truncatedName.foreColor(51))
                } else if isActiveItem {
                    inputHandler.write("• ".yellow + truncatedName.foreColor(250))
                } else {
                    inputHandler.write("  " + truncatedName.foreColor(250))
                }
            }
        }

        // Show scroll indicators if there are more items
        if state.selectableItems.count > maxRows {
            inputHandler.moveTo(row + 1 + maxRows, colX)
            inputHandler.write("⋮".foreColor(250))
        }
    }

    /// Renders the instructions column.
    /// - Parameters:
    ///   - colX: The X position (column) where the column should be rendered.
    ///   - row: The starting row for rendering.
    ///   - maxRows: Maximum number of rows to display.
    ///   - screenWidth: The width of the screen in characters.
    func renderInstructionsColumn(at colX: Int, row: Int, maxRows: Int, screenWidth: Int) {
        // Calculate effective column width (use remaining screen space)
        let effectiveColumnWidth = max(columnWidth, screenWidth - colX - 2)

        // Render column title with [View Only] suffix
        inputHandler.moveTo(row - 1, colX)
        let titleText = "\(state.instructionsTitle) [View Only]"
        let truncatedTitle = truncate(titleText, maxWidth: effectiveColumnWidth - 2)
        let titleStyle = truncatedTitle.foreColor(247)  // Dimmed color for non-selectable
        inputHandler.write(titleStyle)

        // Render separator line under title
        inputHandler.moveTo(row, colX)
        let separatorLength = min(effectiveColumnWidth - 2, max(truncatedTitle.count, 10))
        let separator = String(repeating: "─", count: separatorLength)
        inputHandler.write(separator.foreColor(247))

        // Split instructions into lines and render
        let instructionLines = state.instructions.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let linesToShow = min(instructionLines.count, maxRows)

        for (lineIndex, line) in instructionLines.prefix(linesToShow).enumerated() {
            let lineRow = row + 1 + lineIndex
            inputHandler.moveTo(lineRow, colX)

            // Reserve 2 characters for the indicator
            let maxDisplayWidth = effectiveColumnWidth - 2
            let truncatedLine = truncate(line, maxWidth: maxDisplayWidth)

            // Use dimmed styling with special indicator for instructions
            inputHandler.write("  " + truncatedLine.foreColor(247))
        }

        // Show scroll indicators if there are more lines
        if instructionLines.count > maxRows {
            inputHandler.moveTo(row + 1 + maxRows, colX)
            inputHandler.write("⋮".foreColor(250))
        }
    }

    /// Renders a vertical divider between the two columns.
    /// - Parameters:
    ///   - startRow: The starting row for the divider.
    ///   - maxRows: The maximum number of rows to draw the divider.
    func renderDivider(startRow: Int, maxRows: Int) {
        let dividerChar = "│"
        let dividerX = 1 + columnWidth + (columnSpacing / 2)

        // Draw vertical line from title row to bottom of items
        for row in startRow...(startRow + maxRows + 1) {
            inputHandler.moveTo(row, dividerX)
            inputHandler.write(dividerChar.foreColor(240))
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
        let footerColumnWidth = 30
        let col1X = 1
        let col2X = col1X + footerColumnWidth
        let col3X = col2X + footerColumnWidth

        if state.isMultiSelection {
            // Multi-selection mode footer
            // Column 1: Arrow key navigation
            inputHandler.moveTo(row, col1X)
            inputHandler.write("←→: switch columns")
            inputHandler.moveTo(row + 1, col1X)
            inputHandler.write("↑↓: navigate items")

            // Column 2: Space for toggle
            inputHandler.moveTo(row, col2X)
            if state.activeColumnIndex == 0 {
                inputHandler.write("Space: toggle selection")
            } else {
                inputHandler.write("Space: (cannot select)")
            }
            inputHandler.moveTo(row + 1, col2X)
            inputHandler.write("") // Leave blank

            // Column 3: Enter and Quit
            inputHandler.moveTo(row, col3X)
            if state.activeColumnIndex == 0 {
                let count = state.selectedIndices.count
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

            // Column 2: (empty in static detail mode)
            inputHandler.moveTo(row, col2X)
            inputHandler.write("")
            inputHandler.moveTo(row + 1, col2X)
            inputHandler.write("")

            // Column 3: Enter and Quit
            inputHandler.moveTo(row, col3X)
            if state.activeColumnIndex == 0 {
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
