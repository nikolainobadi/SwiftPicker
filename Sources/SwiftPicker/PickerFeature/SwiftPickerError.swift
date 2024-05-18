//
//  SwiftPickerError.swift
//  
//
//  Created by Nikolai Nobadi on 5/16/24.
//

/// An enumeration of errors that can be thrown by SwiftPicker.
public enum SwiftPickerError: Error {
    
    /// The selection process was cancelled by the user.
    case selectionCancelled
    
    /// Input is required but was not provided.
    case inputRequired
}
