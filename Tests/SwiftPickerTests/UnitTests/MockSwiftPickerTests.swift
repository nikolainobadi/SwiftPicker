//
//  MockSwiftPickerTests.swift
//
//
//  Created by Nikolai Nobadi on 2025-10-24.
//

import Testing
import SwiftPicker
@testable import SwiftPickerTesting

struct MockSwiftPickerTests {
    @Test("Starting values configured correctly")
    func startingValuesConfiguredCorrectly() {
        let sut = makeSUT()

        let permissionResult = sut.getPermission(prompt: "Test")
        let inputResult = sut.getInput(prompt: "Test")

        #expect(permissionResult == true)
        #expect(inputResult.isEmpty)
    }
}


// MARK: - Ordered Permission Tests
extension MockSwiftPickerTests {
    @Test("Returns responses in order from array")
    func returnsResponsesInOrderFromArray() {
        let responses = [true, false, true]
        let sut = makeSUT(mockPermissionType: .ordered(responses))

        let firstResult = sut.getPermission(prompt: "First")
        let secondResult = sut.getPermission(prompt: "Second")
        let thirdResult = sut.getPermission(prompt: "Third")

        #expect(firstResult == true)
        #expect(secondResult == false)
        #expect(thirdResult == true)
    }

    @Test("Returns default value when ordered array is empty")
    func returnsDefaultValueWhenOrderedArrayIsEmpty() {
        let sut = makeSUT(grantPermissionByDefault: false, mockPermissionType: .ordered([]))

        let result = sut.getPermission(prompt: "Test")

        #expect(result == false)
    }

    @Test("Returns default value after all ordered responses used")
    func returnsDefaultValueAfterAllOrderedResponsesUsed() {
        let responses = [true, false]
        let sut = makeSUT(grantPermissionByDefault: false, mockPermissionType: .ordered(responses))

        _ = sut.getPermission(prompt: "First")
        _ = sut.getPermission(prompt: "Second")
        let thirdResult = sut.getPermission(prompt: "Third")

        #expect(thirdResult == false)
    }
}


// MARK: - Dictionary Permission Tests
extension MockSwiftPickerTests {
    @Test("Returns value from dictionary matching prompt title")
    func returnsValueFromDictionaryMatchingPromptTitle() {
        let dictionary = ["Continue?": true, "Delete?": false]
        let sut = makeSUT(mockPermissionType: .dictionary(dictionary))

        let continueResult = sut.getPermission(prompt: "Continue?")
        let deleteResult = sut.getPermission(prompt: "Delete?")

        #expect(continueResult == true)
        #expect(deleteResult == false)
    }

    @Test("Returns default value when prompt not in dictionary")
    func returnsDefaultValueWhenPromptNotInDictionary() {
        let dictionary = ["Continue?": true]
        let sut = makeSUT(grantPermissionByDefault: false, mockPermissionType: .dictionary(dictionary))

        let result = sut.getPermission(prompt: "Unknown?")

        #expect(result == false)
    }

    @Test("Uses default value true when prompt not in dictionary")
    func usesDefaultValueTrueWhenPromptNotInDictionary() {
        let dictionary = ["Continue?": false]
        let sut = makeSUT(grantPermissionByDefault: true, mockPermissionType: .dictionary(dictionary))

        let result = sut.getPermission(prompt: "Unknown?")

        #expect(result == true)
    }
}


// MARK: - Required Permission Tests
extension MockSwiftPickerTests {
    @Test("Completes successfully when permission granted")
    func completesSuccessfullyWhenPermissionGranted() throws {
        let sut = makeSUT(mockPermissionType: .ordered([true]))

        try sut.requiredPermission(prompt: "Continue?")
    }

    @Test("Throws error when permission denied")
    func throwsErrorWhenPermissionDenied() throws {
        let sut = makeSUT(grantPermissionByDefault: false, mockPermissionType: .ordered([false]))

        #expect(throws: SwiftPickerError.self) {
            try sut.requiredPermission(prompt: "Continue?")
        }
    }

    @Test("Throws selection cancelled error when permission denied")
    func throwsSelectionCancelledErrorWhenPermissionDenied() throws {
        let sut = makeSUT(grantPermissionByDefault: false, mockPermissionType: .ordered([false]))

        #expect(throws: SwiftPickerError.selectionCancelled) {
            try sut.requiredPermission(prompt: "Continue?")
        }
    }
}

// MARK: - Ordered Input Tests
extension MockSwiftPickerTests {
    @Test("Returns input responses in order from array")
    func returnsInputResponsesInOrderFromArray() {
        let responses = ["First", "Second", "Third"]
        let sut = makeSUT(mockInputType: .ordered(responses))

        let firstResult = sut.getInput(prompt: "Enter first:")
        let secondResult = sut.getInput(prompt: "Enter second:")
        let thirdResult = sut.getInput(prompt: "Enter third:")

        #expect(firstResult == "First")
        #expect(secondResult == "Second")
        #expect(thirdResult == "Third")
    }

    @Test("Returns default input value when ordered array is empty")
    func returnsDefaultInputValueWhenOrderedArrayIsEmpty() {
        let defaultValue = "default"
        let sut = makeSUT(defaultInputValue: defaultValue, mockInputType: .ordered([]))

        let result = sut.getInput(prompt: "Enter:")

        #expect(result == defaultValue)
    }

    @Test("Returns default input value after all ordered responses used")
    func returnsDefaultInputValueAfterAllOrderedResponsesUsed() {
        let defaultValue = "default"
        let responses = ["First", "Second"]
        let sut = makeSUT(defaultInputValue: defaultValue, mockInputType: .ordered(responses))

        _ = sut.getInput(prompt: "First")
        _ = sut.getInput(prompt: "Second")
        let thirdResult = sut.getInput(prompt: "Third")

        #expect(thirdResult == defaultValue)
    }
}


// MARK: - Dictionary Input Tests
extension MockSwiftPickerTests {
    @Test("Returns input value from dictionary matching prompt title")
    func returnsInputValueFromDictionaryMatchingPromptTitle() {
        let dictionary = ["Name:": "John", "Email:": "john@example.com"]
        let sut = makeSUT(mockInputType: .dictionary(dictionary))

        let nameResult = sut.getInput(prompt: "Name:")
        let emailResult = sut.getInput(prompt: "Email:")

        #expect(nameResult == "John")
        #expect(emailResult == "john@example.com")
    }

    @Test("Returns default input value when prompt not in dictionary")
    func returnsDefaultInputValueWhenPromptNotInDictionary() {
        let defaultValue = "default"
        let dictionary = ["Name:": "John"]
        let sut = makeSUT(defaultInputValue: defaultValue, mockInputType: .dictionary(dictionary))

        let result = sut.getInput(prompt: "Unknown:")

        #expect(result == defaultValue)
    }

    @Test("Uses custom default input value when prompt not in dictionary")
    func usesCustomDefaultInputValueWhenPromptNotInDictionary() {
        let defaultValue = "custom"
        let dictionary = ["Name:": "John"]
        let sut = makeSUT(defaultInputValue: defaultValue, mockInputType: .dictionary(dictionary))

        let result = sut.getInput(prompt: "Unknown:")

        #expect(result == defaultValue)
    }
}


// MARK: - Required Input Tests
extension MockSwiftPickerTests {
    @Test("Returns input when required input provided")
    func returnsInputWhenRequiredInputProvided() throws {
        let expectedInput = "Valid Input"
        let sut = makeSUT(mockInputType: .ordered([expectedInput]))

        let result = try sut.getRequiredInput(prompt: "Enter:")

        #expect(result == expectedInput)
    }

    @Test("Throws error when required input is empty")
    func throwsErrorWhenRequiredInputIsEmpty() throws {
        let sut = makeSUT(defaultInputValue: "", mockInputType: .ordered([]))

        #expect(throws: SwiftPickerError.self) {
            try sut.getRequiredInput(prompt: "Enter:")
        }
    }

    @Test("Throws input required error when required input is empty")
    func throwsInputRequiredErrorWhenRequiredInputIsEmpty() throws {
        let sut = makeSUT(defaultInputValue: "", mockInputType: .ordered([]))

        #expect(throws: SwiftPickerError.inputRequired) {
            try sut.getRequiredInput(prompt: "Enter:")
        }
    }

    @Test("Throws error when ordered input response is empty string")
    func throwsErrorWhenOrderedInputResponseIsEmptyString() throws {
        let sut = makeSUT(mockInputType: .ordered([""]))

        #expect(throws: SwiftPickerError.self) {
            try sut.getRequiredInput(prompt: "Enter:")
        }
    }
}


// MARK: - Custom Prompt Type Tests
extension MockSwiftPickerTests {
    @Test("Supports custom PickerPrompt types with dictionary")
    func supportsCustomPickerPromptTypesWithDictionary() {
        struct CustomPrompt: PickerPrompt {
            let title: String
            let description: String
        }

        let customPrompt = CustomPrompt(title: "Confirm?", description: "Please confirm")
        let dictionary = ["Confirm?": true]
        let sut = makeSUT(mockPermissionType: .dictionary(dictionary))

        let result = sut.getPermission(prompt: customPrompt)

        #expect(result == true)
    }

    @Test("String conforms to PickerPrompt by default")
    func stringConformsToPickerPromptByDefault() {
        let stringPrompt = "Continue?"
        let dictionary = ["Continue?": true]
        let sut = makeSUT(mockPermissionType: .dictionary(dictionary))

        let result = sut.getPermission(prompt: stringPrompt)

        #expect(result == true)
    }

    @Test("Supports custom PickerPrompt types with input dictionary")
    func supportsCustomPickerPromptTypesWithInputDictionary() {
        struct CustomPrompt: PickerPrompt {
            let title: String
            let description: String
        }

        let customPrompt = CustomPrompt(title: "Name:", description: "Enter name")
        let dictionary = ["Name:": "Alice"]
        let sut = makeSUT(mockInputType: .dictionary(dictionary))

        let result = sut.getInput(prompt: customPrompt)

        #expect(result == "Alice")
    }
}

// MARK: - SUT
private extension MockSwiftPickerTests {
    func makeSUT(
        defaultInputValue: String = "",
        grantPermissionByDefault: Bool = true,
        mockInputType: MockInputType = .ordered([]),
        mockPermissionType: MockPermissionType = .ordered([])
    ) -> MockSwiftPicker {
        return .init(
            defaultInputValue: defaultInputValue,
            grantPermissionByDefault: grantPermissionByDefault,
            mockInputType: mockInputType,
            mockPermissionType: mockPermissionType
        )
    }
}
