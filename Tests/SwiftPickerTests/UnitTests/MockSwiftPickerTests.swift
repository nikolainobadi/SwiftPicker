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
        let sut = makeSUT(permissionResult: .init(type: .ordered(responses)))

        let firstResult = sut.getPermission(prompt: "First")
        let secondResult = sut.getPermission(prompt: "Second")
        let thirdResult = sut.getPermission(prompt: "Third")

        #expect(firstResult == true)
        #expect(secondResult == false)
        #expect(thirdResult == true)
    }

    @Test("Returns default value when ordered array is empty")
    func returnsDefaultValueWhenOrderedArrayIsEmpty() {
        let sut = makeSUT(permissionResult: .init(grantByDefault: false, type: .ordered([])))

        let result = sut.getPermission(prompt: "Test")

        #expect(result == false)
    }

    @Test("Returns default value after all ordered responses used")
    func returnsDefaultValueAfterAllOrderedResponsesUsed() {
        let responses = [true, false]
        let sut = makeSUT(permissionResult: .init(grantByDefault: false, type: .ordered(responses)))

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
        let sut = makeSUT(permissionResult: .init(type: .dictionary(dictionary)))

        let continueResult = sut.getPermission(prompt: "Continue?")
        let deleteResult = sut.getPermission(prompt: "Delete?")

        #expect(continueResult == true)
        #expect(deleteResult == false)
    }

    @Test("Returns default value when prompt not in dictionary")
    func returnsDefaultValueWhenPromptNotInDictionary() {
        let dictionary = ["Continue?": true]
        let sut = makeSUT(permissionResult: .init(grantByDefault: false, type: .dictionary(dictionary)))

        let result = sut.getPermission(prompt: "Unknown?")

        #expect(result == false)
    }

    @Test("Uses default value true when prompt not in dictionary")
    func usesDefaultValueTrueWhenPromptNotInDictionary() {
        let dictionary = ["Continue?": false]
        let sut = makeSUT(permissionResult: .init(grantByDefault: true, type: .dictionary(dictionary)))

        let result = sut.getPermission(prompt: "Unknown?")

        #expect(result == true)
    }
}


// MARK: - Required Permission Tests
extension MockSwiftPickerTests {
    @Test("Completes successfully when permission granted")
    func completesSuccessfullyWhenPermissionGranted() throws {
        let sut = makeSUT(permissionResult: .init(type: .ordered([true])))

        try sut.requiredPermission(prompt: "Continue?")
    }

    @Test("Throws error when permission denied")
    func throwsErrorWhenPermissionDenied() throws {
        let sut = makeSUT(permissionResult: .init(grantByDefault: false, type: .ordered([false])))

        #expect(throws: SwiftPickerError.self) {
            try sut.requiredPermission(prompt: "Continue?")
        }
    }

    @Test("Throws selection cancelled error when permission denied")
    func throwsSelectionCancelledErrorWhenPermissionDenied() throws {
        let sut = makeSUT(permissionResult: .init(grantByDefault: false, type: .ordered([false])))

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
        let sut = makeSUT(inputResult: .init(type: .ordered(responses)))

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
        let sut = makeSUT(inputResult: .init(defaultValue: defaultValue, type: .ordered([])))

        let result = sut.getInput(prompt: "Enter:")

        #expect(result == defaultValue)
    }

    @Test("Returns default input value after all ordered responses used")
    func returnsDefaultInputValueAfterAllOrderedResponsesUsed() {
        let defaultValue = "default"
        let responses = ["First", "Second"]
        let sut = makeSUT(inputResult: .init(defaultValue: defaultValue, type: .ordered(responses)))

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
        let sut = makeSUT(inputResult: .init(type: .dictionary(dictionary)))

        let nameResult = sut.getInput(prompt: "Name:")
        let emailResult = sut.getInput(prompt: "Email:")

        #expect(nameResult == "John")
        #expect(emailResult == "john@example.com")
    }

    @Test("Returns default input value when prompt not in dictionary")
    func returnsDefaultInputValueWhenPromptNotInDictionary() {
        let defaultValue = "default"
        let dictionary = ["Name:": "John"]
        let sut = makeSUT(inputResult: .init(defaultValue: defaultValue, type: .dictionary(dictionary)))

        let result = sut.getInput(prompt: "Unknown:")

        #expect(result == defaultValue)
    }

    @Test("Uses custom default input value when prompt not in dictionary")
    func usesCustomDefaultInputValueWhenPromptNotInDictionary() {
        let defaultValue = "custom"
        let dictionary = ["Name:": "John"]
        let sut = makeSUT(inputResult: .init(defaultValue: defaultValue, type: .dictionary(dictionary)))

        let result = sut.getInput(prompt: "Unknown:")

        #expect(result == defaultValue)
    }
}


// MARK: - Required Input Tests
extension MockSwiftPickerTests {
    @Test("Returns input when required input provided")
    func returnsInputWhenRequiredInputProvided() throws {
        let expectedInput = "Valid Input"
        let sut = makeSUT(inputResult: .init(type: .ordered([expectedInput])))

        let result = try sut.getRequiredInput(prompt: "Enter:")

        #expect(result == expectedInput)
    }

    @Test("Throws error when required input is empty")
    func throwsErrorWhenRequiredInputIsEmpty() throws {
        let sut = makeSUT(inputResult: .init(defaultValue: "", type: .ordered([])))

        #expect(throws: SwiftPickerError.self) {
            try sut.getRequiredInput(prompt: "Enter:")
        }
    }

    @Test("Throws input required error when required input is empty")
    func throwsInputRequiredErrorWhenRequiredInputIsEmpty() throws {
        let sut = makeSUT(inputResult: .init(defaultValue: "", type: .ordered([])))

        #expect(throws: SwiftPickerError.inputRequired) {
            try sut.getRequiredInput(prompt: "Enter:")
        }
    }

    @Test("Throws error when ordered input response is empty string")
    func throwsErrorWhenOrderedInputResponseIsEmptyString() throws {
        let sut = makeSUT(inputResult: .init(type: .ordered([""])))

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
        let sut = makeSUT(permissionResult: .init(type: .dictionary(dictionary)))

        let result = sut.getPermission(prompt: customPrompt)

        #expect(result == true)
    }

    @Test("String conforms to PickerPrompt by default")
    func stringConformsToPickerPromptByDefault() {
        let stringPrompt = "Continue?"
        let dictionary = ["Continue?": true]
        let sut = makeSUT(permissionResult: .init(type: .dictionary(dictionary)))

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
        let sut = makeSUT(inputResult: .init(type: .dictionary(dictionary)))

        let result = sut.getInput(prompt: customPrompt)

        #expect(result == "Alice")
    }
}

// MARK: - Single Selection Tests
extension MockSwiftPickerTests {
    @Test("Returns item at ordered selection index")
    func returnsItemAtOrderedSelectionIndex() {
        let items = ["First", "Second", "Third"]
        let sut = makeSUT(selectionResult: .init(singleSelectionType: .ordered([1, 2, 0])))

        let firstResult = sut.singleSelection(title: "Choose:", items: items)
        let secondResult = sut.singleSelection(title: "Choose:", items: items)
        let thirdResult = sut.singleSelection(title: "Choose:", items: items)

        #expect(firstResult == "Second")
        #expect(secondResult == "Third")
        #expect(thirdResult == "First")
    }

    @Test("Returns nil when ordered selection index is nil")
    func returnsNilWhenOrderedSelectionIndexIsNil() {
        let items = ["First", "Second"]
        let sut = makeSUT(selectionResult: .init(singleSelectionType: .ordered([nil])))

        let result = sut.singleSelection(title: "Choose:", items: items)

        #expect(result == nil)
    }

    @Test("Returns item at default selection index when ordered empty")
    func returnsItemAtDefaultSelectionIndexWhenOrderedEmpty() {
        let items = ["First", "Second", "Third"]
        let defaultIndex = 2
        let sut = makeSUT(selectionResult: .init(defaultIndex: defaultIndex, singleSelectionType: .ordered([])))

        let result = sut.singleSelection(title: "Choose:", items: items)

        #expect(result == items[defaultIndex])
    }

    @Test("Returns nil when default selection index is nil")
    func returnsNilWhenDefaultSelectionIndexIsNil() {
        let items = ["First", "Second"]
        let sut = makeSUT(selectionResult: .init(defaultIndex: nil, singleSelectionType: .ordered([])))

        let result = sut.singleSelection(title: "Choose:", items: items)

        #expect(result == nil)
    }

    @Test("Returns item from dictionary selection matching prompt title")
    func returnsItemFromDictionarySelectionMatchingPromptTitle() {
        let items = ["Apple", "Banana", "Cherry"]
        let dictionary = ["Fruit:": 1, "Vegetable:": 2]
        let sut = makeSUT(selectionResult: .init(singleSelectionType: .dictionary(dictionary)))

        let fruitResult = sut.singleSelection(title: "Fruit:", items: items)
        let vegetableResult = sut.singleSelection(title: "Vegetable:", items: items)

        #expect(fruitResult == "Banana")
        #expect(vegetableResult == "Cherry")
    }

    @Test("Returns nil for invalid selection index")
    func returnsNilForInvalidSelectionIndex() {
        let items = ["First", "Second"]
        let sut = makeSUT(selectionResult: .init(singleSelectionType: .ordered([10])))

        let result = sut.singleSelection(title: "Choose:", items: items)

        #expect(result == nil)
    }
}


// MARK: - Required Single Selection Tests
extension MockSwiftPickerTests {
    @Test("Returns item when required single selection index provided")
    func returnsItemWhenRequiredSingleSelectionIndexProvided() throws {
        let items = ["First", "Second", "Third"]
        let sut = makeSUT(selectionResult: .init(singleSelectionType: .ordered([1])))

        let result = try sut.requiredSingleSelection(title: "Choose:", items: items)

        #expect(result == "Second")
    }

    @Test("Throws error when required single selection index is nil")
    func throwsErrorWhenRequiredSingleSelectionIndexIsNil() throws {
        let items = ["First", "Second"]
        let sut = makeSUT(selectionResult: .init(singleSelectionType: .ordered([nil])))

        #expect(throws: SwiftPickerError.self) {
            try sut.requiredSingleSelection(title: "Choose:", items: items)
        }
    }

    @Test("Throws selection cancelled error when required selection is nil")
    func throwsSelectionCancelledErrorWhenRequiredSelectionIsNil() throws {
        let items = ["First", "Second"]
        let sut = makeSUT(selectionResult: .init(defaultIndex: nil, singleSelectionType: .ordered([])))

        #expect(throws: SwiftPickerError.selectionCancelled) {
            try sut.requiredSingleSelection(title: "Choose:", items: items)
        }
    }
}


// MARK: - Multi Selection Tests
extension MockSwiftPickerTests {
    @Test("Returns items at ordered multi selection indices")
    func returnsItemsAtOrderedMultiSelectionIndices() {
        let items = ["First", "Second", "Third", "Fourth"]
        let sut = makeSUT(selectionResult: .init(multiSelectionType: .ordered([[0, 2], [1, 3]])))

        let firstResult = sut.multiSelection(title: "Choose:", items: items)
        let secondResult = sut.multiSelection(title: "Choose:", items: items)

        #expect(firstResult.count == 2)
        #expect(firstResult.contains("First"))
        #expect(firstResult.contains("Third"))
        #expect(secondResult.count == 2)
        #expect(secondResult.contains("Second"))
        #expect(secondResult.contains("Fourth"))
    }

    @Test("Returns empty array when ordered multi selection indices empty")
    func returnsEmptyArrayWhenOrderedMultiSelectionIndicesEmpty() {
        let items = ["First", "Second"]
        let sut = makeSUT(selectionResult: .init(multiSelectionType: .ordered([[]])))

        let result = sut.multiSelection(title: "Choose:", items: items)

        #expect(result.isEmpty)
    }

    @Test("Returns empty array when multi selection ordered list empty")
    func returnsEmptyArrayWhenMultiSelectionOrderedListEmpty() {
        let items = ["First", "Second"]
        let sut = makeSUT(selectionResult: .init(multiSelectionType: .ordered([])))

        let result = sut.multiSelection(title: "Choose:", items: items)

        #expect(result.isEmpty)
    }

    @Test("Returns items from dictionary multi selection matching prompt title")
    func returnsItemsFromDictionaryMultiSelectionMatchingPromptTitle() {
        let items = ["Apple", "Banana", "Cherry", "Date"]
        let dictionary = ["Fruits:": [0, 2], "Other:": [1, 3]]
        let sut = makeSUT(selectionResult: .init(multiSelectionType: .dictionary(dictionary)))

        let fruitsResult = sut.multiSelection(title: "Fruits:", items: items)
        let otherResult = sut.multiSelection(title: "Other:", items: items)

        #expect(fruitsResult.count == 2)
        #expect(fruitsResult.contains("Apple"))
        #expect(fruitsResult.contains("Cherry"))
        #expect(otherResult.count == 2)
        #expect(otherResult.contains("Banana"))
        #expect(otherResult.contains("Date"))
    }

    @Test("Filters out invalid indices from multi selection")
    func filtersOutInvalidIndicesFromMultiSelection() {
        let items = ["First", "Second"]
        let sut = makeSUT(selectionResult: .init(multiSelectionType: .ordered([[0, 10, 1]])))

        let result = sut.multiSelection(title: "Choose:", items: items)

        #expect(result.count == 2)
        #expect(result.contains("First"))
        #expect(result.contains("Second"))
    }
}


// MARK: - SUT
private extension MockSwiftPickerTests {
    func makeSUT(
        inputResult: MockInputResult = .init(),
        permissionResult: MockPermissionResult = .init(),
        selectionResult: MockSelectionResult = .init()
    ) -> MockSwiftPicker {
        return .init(
            inputResult: inputResult,
            permissionResult: permissionResult,
            selectionResult: selectionResult
        )
    }
}
