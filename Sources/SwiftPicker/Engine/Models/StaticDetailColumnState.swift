//
//  StaticDetailColumnState.swift
//
//
//  Created by Nikolai Nobadi on 11/16/25.
//

/// A class representing the state of static detail column selection in `InteractivePicker`.
/// Displays a selectable column on the left and static instructions on the right.
final class StaticDetailColumnState<Item: DisplayablePickerItem> {
    /// The line position of the top line in the selection display.
    let topLine: Int

    /// The title to display at the top of the column selection.
    var title: String

    /// The selectable items displayed in the first column.
    let selectableItems: [Item]

    /// The static instructions displayed in the second column.
    let instructions: String

    /// The title for the selectable column.
    let selectableTitle: String

    /// The title for the instructions column.
    let instructionsTitle: String

    /// The index of the currently active item in the selectable column.
    var activeIndex: Int

    /// The index of the currently active column (0 for selectable, 1 for instructions).
    var activeColumnIndex: Int

    /// Whether this is in multi-selection mode (Space toggles selection, Enter confirms all).
    let isMultiSelection: Bool

    /// The indices of selected items in multi-selection mode.
    var selectedIndices: Set<Int>

    /// Initializes a new instance of `StaticDetailColumnState`.
    /// - Parameters:
    ///   - selectableItems: The items displayed in the selectable column.
    ///   - instructions: The static instructions displayed in the second column.
    ///   - selectableTitle: The title for the selectable column.
    ///   - instructionsTitle: The title for the instructions column.
    ///   - title: The main title to display at the top.
    ///   - topLine: The line position of the top line in the selection display.
    ///   - isMultiSelection: Whether this is in multi-selection mode. Defaults to false.
    init(selectableItems: [Item], instructions: String, selectableTitle: String, instructionsTitle: String, title: String, topLine: Int, isMultiSelection: Bool = false) {
        self.selectableItems = selectableItems
        self.instructions = instructions
        self.selectableTitle = selectableTitle
        self.instructionsTitle = instructionsTitle
        self.title = title
        self.topLine = topLine
        self.activeIndex = 0
        self.activeColumnIndex = 0  // Start with selectable column active
        self.isMultiSelection = isMultiSelection
        self.selectedIndices = []
    }
}


// MARK: - Helper Methods
extension StaticDetailColumnState {
    /// The currently active item in the selectable column.
    var activeItem: Item? {
        guard activeIndex >= 0 && activeIndex < selectableItems.count else { return nil }
        return selectableItems[activeIndex]
    }

    /// The selected items in multi-selection mode.
    var selectedItems: [Item] {
        return selectedIndices.sorted().compactMap { index in
            guard index >= 0 && index < selectableItems.count else { return nil }
            return selectableItems[index]
        }
    }

    /// Checks if an item at the given index is selected.
    /// - Parameter index: The index to check.
    /// - Returns: True if the item is selected, false otherwise.
    func isSelected(at index: Int) -> Bool {
        return selectedIndices.contains(index)
    }

    /// Toggles the selection state of the currently active item.
    func toggleSelection() {
        if selectedIndices.contains(activeIndex) {
            selectedIndices.remove(activeIndex)
        } else {
            selectedIndices.insert(activeIndex)
        }
    }

    /// The text to display at the top line of the column selection.
    var topLineText: String {
        if isMultiSelection {
            return "InteractivePicker (static-detail multi-selection)"
        } else {
            return "InteractivePicker (static-detail selection)"
        }
    }
}
