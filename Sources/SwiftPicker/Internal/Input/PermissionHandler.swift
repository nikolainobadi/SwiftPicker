//
//  PermissionHandler.swift
//
//
//  Created by Nikolai Nobadi on 5/17/24.
//

internal enum PermissionHandler {
    static func getPermission(_ prompt: String, retryCount: Int = 0) -> Bool {
        print(prompt, terminator: " (\("y".green)/\("n".red)) ")
        guard let answer = readLine(), !answer.isEmpty else {
            if retryCount > 2 {
                print("Fine, I'll take that as a no!".red)
                return false
            } else {
                print("type 'y' or 'n'\n".yellow)
                return getPermission(prompt, retryCount: retryCount + 1)
            }
        }
        
        return answer == "y" || answer == "Y"
    }
}
