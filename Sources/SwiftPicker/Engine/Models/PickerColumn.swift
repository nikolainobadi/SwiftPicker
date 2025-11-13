//
//  PickerColumn.swift
//
//
//  Created by Nikolai Nobadi on 11/8/25.
//

/// Represents a single column in a multi-column picker.
/// Contains a title, a list of items, and tracks the currently active item within the column.
public struct PickerColumn<Item: DisplayablePickerItem> {
    /// The title displayed at the top of the column.
    public let title: String

    /// The list of items available for selection in this column.
    public let items: [Item]

    /// The index of the currently active item in the column.
    public var activeIndex: Int

    /// Whether items in this column can be selected with the Enter key.
    /// When false, the column is for display/navigation only.
    public let isSelectable: Bool

    /// Set of indices for items that are selected (used in multi-selection mode).
    var selectedIndices: Set<Int>

    /// Initializes a new picker column.
    /// - Parameters:
    ///   - title: The title to display at the top of the column.
    ///   - items: The list of items available for selection.
    ///   - activeIndex: The index of the initially active item. Defaults to 0.
    ///   - isSelectable: Whether items can be selected from this column. Defaults to true.
    public init(title: String, items: [Item], activeIndex: Int = 0, isSelectable: Bool = true) {
        self.title = title
        self.items = items
        self.activeIndex = activeIndex
        self.isSelectable = isSelectable
        self.selectedIndices = []
    }

    /// The currently active item in the column, or nil if the activeIndex is out of bounds.
    public var activeItem: Item? {
        guard activeIndex >= 0, activeIndex < items.count else { return nil }
        return items[activeIndex]
    }

    /// The selected items in this column (used in multi-selection mode).
    var selectedItems: [Item] {
        return selectedIndices.sorted().compactMap { index in
            guard index >= 0, index < items.count else { return nil }
            return items[index]
        }
    }

    /// Toggles the selection state of the item at the current active index.
    mutating func toggleSelection() {
        if selectedIndices.contains(activeIndex) {
            selectedIndices.remove(activeIndex)
        } else {
            selectedIndices.insert(activeIndex)
        }
    }

    /// Checks if the item at the given index is selected.
    func isSelected(at index: Int) -> Bool {
        return selectedIndices.contains(index)
    }
}
