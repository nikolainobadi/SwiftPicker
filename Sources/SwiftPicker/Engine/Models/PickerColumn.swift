//
//  PickerColumn.swift
//
//
//  Created by Nikolai Nobadi on 11/8/25.
//

/// Represents a single column in a multi-column picker.
/// Contains a title, a list of items, and tracks the currently active item within the column.
struct PickerColumn<Item: DisplayablePickerItem> {
    /// The title displayed at the top of the column.
    let title: String

    /// The list of items available for selection in this column.
    let items: [Item]

    /// The index of the currently active item in the column.
    var activeIndex: Int

    /// Initializes a new picker column.
    /// - Parameters:
    ///   - title: The title to display at the top of the column.
    ///   - items: The list of items available for selection.
    ///   - activeIndex: The index of the initially active item. Defaults to 0.
    init(title: String, items: [Item], activeIndex: Int = 0) {
        self.title = title
        self.items = items
        self.activeIndex = activeIndex
    }

    /// The currently active item in the column, or nil if the activeIndex is out of bounds.
    var activeItem: Item? {
        guard activeIndex >= 0, activeIndex < items.count else { return nil }
        return items[activeIndex]
    }
}
