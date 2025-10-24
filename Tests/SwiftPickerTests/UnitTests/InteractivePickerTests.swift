//
//  InteractivePickerTests.swift
//
//
//  Created by Nikolai Nobadi on 5/17/24.
//

import Testing
@testable import SwiftPicker

struct InteractivePickerTests {
    @Test("Returns user input from text prompt")
    func returnsUserInputFromTextPrompt() {
        let expectedInput = "Test Input"
        let prompt = "Enter something:"
        let (sut, textHandler, _) = makeSUT(inputToReturn: expectedInput)

        let result = sut.getInput(prompt: prompt)

        #expect(result == expectedInput)
        #expect(textHandler.getInputCallCount == 1)
        #expect(textHandler.lastInputPrompt == prompt)
    }

    @Test("Returns user permission response when prompted")
    func returnsUserPermissionResponseWhenPrompted() {
        let prompt = "Do you agree?"
        let (sut, textHandler, _) = makeSUT(permissionToReturn: true)

        let result = sut.getPermission(prompt: prompt)

        #expect(result == true)
        #expect(textHandler.getPermissionCallCount == 1)
        #expect(textHandler.lastPermissionPrompt == prompt)
    }

    @Test("Returns required input when user provides text")
    func returnsRequiredInputWhenUserProvidesText() throws {
        let expectedInput = "Valid Input"
        let prompt = "Enter required text:"
        let (sut, textHandler, _) = makeSUT(inputToReturn: expectedInput)

        let result = try sut.getRequiredInput(prompt: prompt)

        #expect(result == expectedInput)
        #expect(textHandler.getInputCallCount == 1)
    }

    @Test("Throws error when required input is empty")
    func throwsErrorWhenRequiredInputIsEmpty() throws {
        let prompt = "Enter required text:"
        let (sut, _, _) = makeSUT(inputToReturn: "")

        #expect(throws: SwiftPickerError.self) {
            try sut.getRequiredInput(prompt: prompt)
        }
    }

    @Test("Completes successfully when required permission is granted")
    func completesSuccessfullyWhenRequiredPermissionIsGranted() throws {
        let prompt = "Continue?"
        let (sut, textHandler, _) = makeSUT(permissionToReturn: true)

        try sut.requiredPermission(prompt: prompt)

        #expect(textHandler.getPermissionCallCount == 1)
    }

    @Test("Throws error when required permission is denied")
    func throwsErrorWhenRequiredPermissionIsDenied() throws {
        let prompt = "Continue?"
        let (sut, _, _) = makeSUT(permissionToReturn: false)

        #expect(throws: SwiftPickerError.self) {
            try sut.requiredPermission(prompt: prompt)
        }
    }
}

// MARK: - Single Selection Tests
extension InteractivePickerTests {
    @Test("Returns selected item from single selection")
    func returnsSelectedItemFromSingleSelection() {
        let items = ["Item 1", "Item 2", "Item 3"]
        let (sut, _, pickerInput) = makeSUT()

        pickerInput.pressKey = true
        pickerInput.enqueueSpecialChar(specialChar: .enter)

        let result = sut.singleSelection(title: "Choose one:", items: items)

        #expect(result == items[0])
    }

    @Test("Returns nil when user quits single selection")
    func returnsNilWhenUserQuitsSingleSelection() {
        let items = ["Item 1", "Item 2"]
        let (sut, _, pickerInput) = makeSUT()

        pickerInput.pressKey = true
        pickerInput.enqueueSpecialChar(specialChar: .quit)

        let result = sut.singleSelection(title: "Choose one:", items: items)

        #expect(result == nil)
    }

    @Test("Returns selected item when required single selection is made")
    func returnsSelectedItemWhenRequiredSingleSelectionIsMade() throws {
        let items = ["Item 1", "Item 2", "Item 3"]
        let (sut, _, pickerInput) = makeSUT()

        pickerInput.pressKey = true
        pickerInput.enqueueSpecialChar(specialChar: .enter)

        let result = try sut.requiredSingleSelection(title: "Choose one:", items: items)

        #expect(result == items[0])
    }

    @Test("Throws error when user quits required single selection")
    func throwsErrorWhenUserQuitsRequiredSingleSelection() throws {
        let items = ["Item 1", "Item 2"]
        let (sut, _, pickerInput) = makeSUT()

        pickerInput.pressKey = true
        pickerInput.enqueueSpecialChar(specialChar: .quit)

        #expect(throws: SwiftPickerError.self) {
            try sut.requiredSingleSelection(title: "Choose one:", items: items)
        }
    }
}

// MARK: - Multi Selection Tests
extension InteractivePickerTests {
    @Test("Returns selected items from multi selection")
    func returnsSelectedItemsFromMultiSelection() {
        let items = ["Item 1", "Item 2", "Item 3"]
        let (sut, _, pickerInput) = makeSUT(directionKey: .down)

        pickerInput.pressKey = true
        pickerInput.enqueueSpecialChar(specialChar: .space)
        pickerInput.enqueueSpecialChar(specialChar: .space)
        pickerInput.enqueueSpecialChar(specialChar: .enter)

        let result = sut.multiSelection(title: "Choose multiple:", items: items)

        #expect(result.count == 2)
        #expect(result.contains(items[0]))
        #expect(result.contains(items[1]))
    }

    @Test("Returns empty array when user quits multi selection")
    func returnsEmptyArrayWhenUserQuitsMultiSelection() {
        let items = ["Item 1", "Item 2"]
        let (sut, _, pickerInput) = makeSUT()

        pickerInput.pressKey = true
        pickerInput.enqueueSpecialChar(specialChar: .quit)

        let result = sut.multiSelection(title: "Choose multiple:", items: items)

        #expect(result.isEmpty)
    }

    @Test("Returns empty array when no items selected in multi selection")
    func returnsEmptyArrayWhenNoItemsSelectedInMultiSelection() {
        let items = ["Item 1", "Item 2", "Item 3"]
        let (sut, _, pickerInput) = makeSUT()

        pickerInput.pressKey = true
        pickerInput.enqueueSpecialChar(specialChar: .enter)

        let result = sut.multiSelection(title: "Choose multiple:", items: items)

        #expect(result.isEmpty)
    }
}

// MARK: - Protocol Conformance Tests
extension InteractivePickerTests {
    @Test("Supports string prompt conformance")
    func supportsStringPromptConformance() {
        let stringPrompt = "Simple prompt"
        let (sut, textHandler, _) = makeSUT(inputToReturn: "Response")

        let result = sut.getInput(prompt: stringPrompt)

        #expect(result == "Response")
        #expect(textHandler.lastInputPrompt == stringPrompt)
    }

    @Test("Supports custom DisplayablePickerItem types")
    func supportsCustomDisplayablePickerItemTypes() {
        struct CustomItem: DisplayablePickerItem {
            let id: Int
            let name: String
            var displayName: String { return name }
        }

        let items = [
            CustomItem(id: 1, name: "First"),
            CustomItem(id: 2, name: "Second")
        ]
        let (sut, _, pickerInput) = makeSUT()

        pickerInput.pressKey = true
        pickerInput.enqueueSpecialChar(specialChar: .enter)

        let result = sut.singleSelection(title: "Choose:", items: items)

        #expect(result?.id == items[0].id)
        #expect(result?.name == items[0].name)
    }
}

// MARK: - SUT
private extension InteractivePickerTests {
    func makeSUT(
        inputToReturn: String = "",
        permissionToReturn: Bool = false,
        directionKey: Direction? = nil,
        screenSize: (Int, Int) = (30, 100)
    ) -> (sut: InteractivePicker, textHandler: MockTextInputHandler, pickerInput: MockInput) {
        let textHandler = MockTextInputHandler(inputToReturn: inputToReturn, permissionToReturn: permissionToReturn)
        let pickerInput = MockInput(screenSize: screenSize, directionKey: directionKey)
        let sut = InteractivePicker(textInputHandler: textHandler, pickerInputHandler: pickerInput)

        return (sut, textHandler, pickerInput)
    }
}
