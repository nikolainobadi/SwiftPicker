//
//  Option.swift
//  
//
//  Created by Nikolai Nobadi on 5/14/24.
//

internal struct Option<Item: DisplayablePickerItem> {
    let item: Item
    let line: Int
    var isSelected: Bool = false
}
