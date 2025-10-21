//
//  PickerInfo.swift
//  
//
//  Created by Nikolai Nobadi on 5/16/24.
//

/// A structure containing the title and items for the `SwiftPicker` selection list.
internal struct PickerInfo<Item: DisplayablePickerItem> {
    /// The title to display at the top of the selection list.
    let title: String
    
    /// The list of items to select from.
    let items: [Item]
}
