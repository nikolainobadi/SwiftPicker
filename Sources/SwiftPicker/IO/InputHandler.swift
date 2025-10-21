//
//  InputHandler.swift
//
//
//  Created by Nikolai Nobadi on 5/17/24.
//

/// An enumeration for handling user input in `SwiftPicker`.
/// Provides methods to prompt for permissions and retrieve user input.
internal enum InputHandler {
    /// Prompts the user for permission with a yes/no question.
    /// - Parameters:
    ///   - prompt: The prompt message to display to the user.
    ///   - retryCount: The number of times the user has been prompted (used for retry logic).
    /// - Returns: `true` if the user grants permission, `false` otherwise.
    static func getPermission(_ prompt: String, retryCount: Int = 0) -> Bool {
        print("\n\(prompt)", terminator: " (\("y".green)/\("n".red)) ")
        guard let answer = readLine(), !answer.isEmpty else {
            if retryCount > 1 {
                print("Fine, I'll take that as a no!".red)
                return false
            } else {
                print("type 'y' or 'n'\n".yellow)
                return getPermission(prompt, retryCount: retryCount + 1)
            }
        }
        
        return answer == "y" || answer == "Y"
    }
    
    /// Prompts the user for input with the given prompt string.
    /// - Parameters:
    ///   - prompt: The prompt message to display to the user.
    ///   - retryCount: The number of times the user has been prompted (used for retry logic).
    /// - Returns: The user's input as a String.
    static func getInput(_ prompt: String, retryCount: Int = 0) -> String {
        print("\(prompt)\n")
        if let name = readLine(), !name.isEmpty {
            return name
        }
        
        guard retryCount < 2 else {
            return ""
        }
        
        guard getPermission("\nYou didn't type anything. Would you like to try again?") else {
            return ""
        }
        
        return getInput(prompt, retryCount: retryCount + 1)
    }
}
