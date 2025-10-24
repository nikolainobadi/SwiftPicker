//
//  MockTextInputHandler.swift
//
//
//  Created by Nikolai Nobadi on 5/17/24.
//

@testable import SwiftPicker

final class MockTextInputHandler: TextInputHandler {
    private let inputToReturn: String
    private let permissionToReturn: Bool

    private(set) var getInputCallCount = 0
    private(set) var getPermissionCallCount = 0
    private(set) var lastInputPrompt: String?
    private(set) var lastPermissionPrompt: String?

    init(inputToReturn: String = "", permissionToReturn: Bool = false) {
        self.inputToReturn = inputToReturn
        self.permissionToReturn = permissionToReturn
    }

    func getInput(_ prompt: String) -> String {
        getInputCallCount += 1
        lastInputPrompt = prompt
        return inputToReturn
    }

    func getPermission(_ prompt: String) -> Bool {
        getPermissionCallCount += 1
        lastPermissionPrompt = prompt
        return permissionToReturn
    }
}
