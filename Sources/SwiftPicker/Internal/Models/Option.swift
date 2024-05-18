//
//  Option.swift
//  
//
//  Created by Nikolai Nobadi on 5/14/24.
//

/// A structure representing an option in the `SwiftPicker` selection list.
/// Each option contains an item conforming to `DisplayablePickerItem`, its line position in the list, and its selection state.
internal struct Option<Item: DisplayablePickerItem> {
    /// The item represented by this option.
    let item: Item
    
    /// The line position of this option in the selection list.
    let line: Int
    
    /// A Boolean value indicating whether this option is selected.
    var isSelected: Bool = false
    
    /// The display name of the item, as specified by the `DisplayablePickerItem` protocol.
    var title: String {
        return item.displayName
    }
}

