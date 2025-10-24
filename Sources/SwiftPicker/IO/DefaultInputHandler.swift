//
//  DefaultInputHandler.swift
//
//
//  Created by Nikolai Nobadi on 5/17/24.
//

/// Default implementation of `TextInputHandler` that delegates to the static `InputHandler` methods.
struct DefaultInputHandler: TextInputHandler {
    func getInput(_ prompt: String) -> String {
        return InputHandler.getInput(prompt)
    }

    func getPermission(_ prompt: String) -> Bool {
        return InputHandler.getPermission(prompt)
    }
}
