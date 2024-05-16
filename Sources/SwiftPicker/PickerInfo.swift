//
//  PickerInfo.swift
//  
//
//  Created by Nikolai Nobadi on 5/16/24.
//

internal struct PickerInfo<Item: DisplayablePickerItem> {
    let title: String
    let items: [Item]
    let padding: PickerPadding
}
