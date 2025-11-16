//
//  CommandLineColumnSelection.swift
//  SwiftPicker
//
//  Created by Nikolai Nobadi on 3/26/25.
//

/// A protocol defining methods for command line column-based selection.
public protocol CommandLineColumnSelection {
    /// Displays multiple columns for navigation and selection.
    func dualColumnSelection<Item: DisplayablePickerItem>(columns: [PickerColumn<Item>], title: PickerPrompt, newScreen: Bool, onNavigate: ((Item) -> (items: [Item], title: String)?)?) -> Item?

    /// Displays multiple columns for navigation and selection and requires a selection.
    func requiredDualColumnSelection<Item: DisplayablePickerItem>(columns: [PickerColumn<Item>], title: PickerPrompt, newScreen: Bool, onNavigate: ((Item) -> (items: [Item], title: String)?)?) throws -> Item

    /// Displays a dual-column layout with one selectable column and one static display column.
    func singleSelectStaticDetailColumnSelection<Item: DisplayablePickerItem>(selectableItems: [Item], staticDisplayItems: [Item], selectableTitle: String, displayTitle: String, title: PickerPrompt, newScreen: Bool) -> Item?

    /// Displays a dual-column layout with one selectable column and one static display column and requires a selection.
    func requiredSingleSelectStaticDetailColumnSelection<Item: DisplayablePickerItem>(selectableItems: [Item], staticDisplayItems: [Item], selectableTitle: String, displayTitle: String, title: PickerPrompt, newScreen: Bool) throws -> Item

    /// Displays a dual-column layout with multi-selection in the first column and a static display in the second.
    func multiSelectStaticDetailColumnSelection<Item: DisplayablePickerItem>(selectableItems: [Item], staticDisplayItems: [Item], selectableTitle: String, displayTitle: String, title: PickerPrompt, newScreen: Bool) -> [Item]

    /// Displays a dual-column layout with multi-selection in the first column and a dynamic display in the second.
    func multiSelectDynamicDetailColumnSelection<Item: DisplayablePickerItem>(selectableItems: [Item], selectableTitle: String, displayTitle: String, title: PickerPrompt, newScreen: Bool, onActiveItemChange: @escaping (Item) -> [Item]) -> [Item]
}
