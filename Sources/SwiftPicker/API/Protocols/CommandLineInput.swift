//
//  CommandLineInput.swift
//  SwiftPicker
//
//  Created by Nikolai Nobadi on 3/26/25.
//

/// A protocol defining methods for command line text input.
public protocol CommandLineInput {
    /// Prompts the user for input with the given prompt.
    func getInput(prompt: PickerPrompt) -> String
    
    /// Prompts the user for input with the given prompt and requires non-empty input.
    func getRequiredInput(prompt: PickerPrompt) throws -> String
}

// MARK: - Input Convenience Methods
public extension CommandLineInput {
    func getInput(_ prompt: PickerPrompt) -> String {
        return getInput(prompt: prompt)
    }
    
    func getRequiredInput(_ prompt: PickerPrompt) throws -> String {
        return try getRequiredInput(prompt: prompt)
    }
}