//
//  InputHandler.swift
//
//
//  Created by Nikolai Nobadi on 5/17/24.
//

internal enum InputHandler {
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
