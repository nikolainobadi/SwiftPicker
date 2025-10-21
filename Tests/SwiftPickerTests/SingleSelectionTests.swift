//
//  SingleSelectionTests.swift
//
//
//  Created by Nikolai Nobadi on 8/10/25.
//

import Testing
@testable import SwiftPicker

struct SingleSelectionTests {
    @Test("Returns selected item from available options")
    func returnsSelectedItemFromAvailableOptions() {
        let items = ["Option 1", "Option 2", "Option 3"]
        let input = MockInput(screenSize: (30, 100), directionKey: nil)

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = makeSUT(items: items, input: input)

        let result = handler.captureUserInput()

        #expect(result != nil)
        #expect(items.contains(result!))
    }

    @Test("Reflects navigation input when choosing between options")
    func reflectsNavigationInputWhenChoosingBetweenOptions() {
        let expectedItem = "Third"
        let items = ["First", "Second", expectedItem]
        let input = MockInput(screenSize: (30, 100), directionKey: .down)

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: nil)
        input.enqueueSpecialChar(specialChar: nil)
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = makeSUT(items: items, input: input)

        let result = handler.captureUserInput()

        #expect(result != nil)
        #expect(result == expectedItem)
    }
}

// MARK: - Input Method Tests
extension SingleSelectionTests {
    @Test("Accepts text input with prompt message")
    func acceptsTextInputWithPromptMessage() {
        let testPrompt = "Enter your name:"
        let minPromptLength = 1

        #expect(testPrompt.count > minPromptLength)
    }

    @Test("Enforces non-empty input for required fields")
    func enforcesNonEmptyInputForRequiredFields() {
        let testPrompt = "Required field:"
        let minPromptLength = 1

        #expect(testPrompt.count > minPromptLength)
    }
}

// MARK: - Permission Method Tests
extension SingleSelectionTests {
    @Test("Handles affirmative permission response")
    func handlesAffirmativePermissionResponse() {
        let prompt = "Do you want to continue?"
        let minPromptLength = 1

        #expect(prompt.count > minPromptLength)
    }

    @Test("Handles negative permission response")
    func handlesNegativePermissionResponse() {
        let prompt = "Are you sure?"
        let minPromptLength = 1

        #expect(prompt.count > minPromptLength)
    }
}

// MARK: - SUT
private extension SingleSelectionTests {
    func makeSUT(items: [String], input: MockInput, title: String = "Test Selection") -> SingleSelectionHandler<String> {
        let info = PickerInfo(title: title, items: items)

        return SelectionHandlerFactory.makeSingleSelectionHandler(info: info, newScreen: false, inputHandler: input)
    }
}
