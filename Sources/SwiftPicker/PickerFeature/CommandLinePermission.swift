//
//  CommandLinePermission.swift
//  SwiftPicker
//
//  Created by Nikolai Nobadi on 3/26/25.
//

/// A protocol defining methods for command line yes/no permissions.
public protocol CommandLinePermission {
    /// Prompts the user for permission with a yes/no question.
    func getPermission(prompt: PickerPrompt) -> Bool
    
    /// Prompts the user for permission with a yes/no question and requires a yes to proceed.
    func requiredPermission(prompt: PickerPrompt) throws
}

// MARK: - Permission Convenience Methods
public extension CommandLinePermission {
    func getPermission(_ prompt: PickerPrompt) -> Bool {
        return getPermission(prompt: prompt)
    }
    
    func requiredPermission(_ prompt: PickerPrompt) throws {
        return try requiredPermission(prompt: prompt)
    }
}