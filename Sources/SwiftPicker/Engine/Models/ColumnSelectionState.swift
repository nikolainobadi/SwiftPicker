//
//  ColumnSelectionState.swift
//
//
//  Created by Nikolai Nobadi on 11/8/25.
//

/// A class representing the state of multi-column selection in `InteractivePicker`.
/// This includes the columns, active column index, title, and top line position.
final class ColumnSelectionState<Item: DisplayablePickerItem> {
    /// The line position of the top line in the selection display.
    let topLine: Int

    /// The title to display at the top of the column selection.
    /// This can be updated during navigation to show breadcrumb trails.
    var title: String

    /// The index of the currently active column.
    var activeColumnIndex: Int

    /// The list of columns available for selection.
    var columns: [PickerColumn<Item>]

    /// Initializes a new instance of `ColumnSelectionState`.
    /// - Parameters:
    ///   - columns: The list of columns to display.
    ///   - activeColumnIndex: The index of the initially active column. Defaults to 0.
    ///   - title: The title to display at the top of the column selection.
    ///   - topLine: The line position of the top line in the selection display.
    init(columns: [PickerColumn<Item>], activeColumnIndex: Int = 0, title: String, topLine: Int) {
        self.columns = columns
        self.activeColumnIndex = max(0, min(activeColumnIndex, columns.count - 1))
        self.title = title
        self.topLine = topLine
    }
}


// MARK: - Helper Methods
extension ColumnSelectionState {
    /// The currently active column.
    var activeColumn: PickerColumn<Item> {
        get { columns[activeColumnIndex] }
        set { columns[activeColumnIndex] = newValue }
    }

    /// The text to display at the top line of the column selection.
    var topLineText: String {
        return "InteractivePicker (column-selection)"
    }

    /// The text to display at the bottom line of the column selection.
    var bottomLineText: String {
        return "Use ←→ to switch columns, ↑↓ to navigate • Enter to select • Q to quit"
    }
}
