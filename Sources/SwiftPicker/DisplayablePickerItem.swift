//
//  DisplayablePickerItem.swift
//  
//
//  Created by Nikolai Nobadi on 5/14/24.
//

public protocol DisplayablePickerItem {
    /// A string representation of the item that can be used for display purposes.
    var displayName: String { get }
}

extension String: DisplayablePickerItem {
    public var displayName: String { self }
}
