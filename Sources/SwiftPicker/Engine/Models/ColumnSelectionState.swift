//
//  ColumnSelectionState.swift
//
//
//  Created by Nikolai Nobadi on 11/8/25.
//

/// A class representing the state of multi-column selection in `InteractivePicker`.
/// Maintains full navigation history with a 2-column visible window.
final class ColumnSelectionState<Item: DisplayablePickerItem> {
    /// The line position of the top line in the selection display.
    let topLine: Int

    /// The title to display at the top of the column selection.
    /// This can be updated during navigation to show breadcrumb trails.
    var title: String

    /// The index of the currently active column within the visible window (0 or 1).
    var activeColumnIndex: Int

    /// The full navigation history stack. Never shrinks, only grows.
    var navigationStack: [PickerColumn<Item>]

    /// The index in navigationStack where the visible 2-column window starts.
    var visibleStartIndex: Int

    /// Whether this is in multi-selection mode (Space toggles selection, Enter confirms all).
    let isMultiSelection: Bool

    /// Initializes a new instance of `ColumnSelectionState`.
    /// - Parameters:
    ///   - columns: The initial list of columns to display.
    ///   - activeColumnIndex: The index of the initially active column. Defaults to 0.
    ///   - title: The title to display at the top of the column selection.
    ///   - topLine: The line position of the top line in the selection display.
    ///   - isMultiSelection: Whether this is in multi-selection mode. Defaults to false.
    init(columns: [PickerColumn<Item>], activeColumnIndex: Int = 0, title: String, topLine: Int, isMultiSelection: Bool = false) {
        self.navigationStack = columns
        self.visibleStartIndex = 0
        self.activeColumnIndex = max(0, min(activeColumnIndex, columns.count - 1))
        self.title = title
        self.topLine = topLine
        self.isMultiSelection = isMultiSelection
    }
}


// MARK: - Helper Methods
extension ColumnSelectionState {
    /// The visible 2-column window derived from the navigation stack.
    var columns: [PickerColumn<Item>] {
        let endIndex = min(visibleStartIndex + 2, navigationStack.count)
        return Array(navigationStack[visibleStartIndex..<endIndex])
    }

    /// The currently active column within the visible window.
    var activeColumn: PickerColumn<Item> {
        get {
            let stackIndex = visibleStartIndex + activeColumnIndex
            return navigationStack[stackIndex]
        }
        set {
            let stackIndex = visibleStartIndex + activeColumnIndex
            navigationStack[stackIndex] = newValue
        }
    }

    /// The text to display at the top line of the column selection.
    var topLineText: String {
        if isMultiSelection {
            return "InteractivePicker (multi-column selection)"
        } else {
            return "InteractivePicker (column-selection)"
        }
    }
}
