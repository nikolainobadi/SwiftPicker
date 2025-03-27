//
//  DisplayablePickerItem.swift
//  
//
//  Created by Nikolai Nobadi on 5/14/24.
//

/// A protocol that defines an item that can be displayed in the `SwiftPicker`.
/// Types conforming to this protocol must provide a string representation for display purposes.
public protocol DisplayablePickerItem {
    
    /// A string representation of the item that can be used for display purposes.
    var displayName: String { get }
}

/// Extends the String type to conform to the `DisplayablePickerItem` protocol.
extension String: DisplayablePickerItem {
    
    /// A string representation of the string itself.
    public var displayName: String { self }
}
