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
        let result = sut.getPermission(prompt: "Test")

        #expect(result == true)
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

        do {
            try sut.requiredPermission(prompt: "Continue?")
            #expect(Bool(false), "Should have thrown error")
        } catch let error as SwiftPickerError {
            #expect(error == .selectionCancelled)
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
}

// MARK: - SUT
private extension MockSwiftPickerTests {
    func makeSUT(
        grantPermissionByDefault: Bool = true,
        mockPermissionType: MockPermissionType = .ordered([])
    ) -> MockSwiftPicker {
        return .init(
            grantPermissionByDefault: grantPermissionByDefault,
            mockPermissionType: mockPermissionType
        )
    }
}
