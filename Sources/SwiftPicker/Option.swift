//
//  Option.swift
//  
//
//  Created by Nikolai Nobadi on 5/14/24.
//

internal struct Option {
    /// The display text for this option
    let title: String
    
    /// The line number where this option is rendered
    let line: Int
    
    /// Indicates if this option is selected
    var isSelected: Bool = false
}
