//
//  MultiSelectionTests.swift
//
//
//  Created by Nikolai Nobadi on 8/10/25.
//

import Testing
@testable import SwiftPicker

struct MultiSelectionTests {
    @Test("Allows selection of multiple items in a single session")
    func allowsSelectionOfMultipleItemsInSingleSession() {
        let firstItem = "A"
        let secondItem = "B"
        let items = [firstItem, secondItem, "C", "D"]
        let input = MockInput(screenSize: (30, 100), directionKey: .down)
        let expectedCount = 2

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .space)
        input.enqueueSpecialChar(specialChar: .space)
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = makeSUT(items: items, input: input)

        let result = handler.captureUserInput()

        #expect(result.count == expectedCount)
        #expect(result.contains(firstItem))
        #expect(result.contains(secondItem))
    }

    @Test("Supports toggling item selection state")
    func supportsTogglingItemSelectionState() {
        let items = ["X", "Y", "Z"]
        let input = MockInput(screenSize: (30, 100), directionKey: nil)

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .space)
        input.enqueueSpecialChar(specialChar: .space)
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = makeSUT(items: items, input: input)

        let result = handler.captureUserInput()

        #expect(result.isEmpty)
    }
}

// MARK: - SUT
private extension MultiSelectionTests {
    func makeSUT(items: [String], input: MockInput, title: String = "Test Selection") -> MultiSelectionHandler<String> {
        let info = PickerInfo(title: title, items: items)

        return SelectionHandlerFactory.makeMultiSelectionHandler(info: info, newScreen: false, inputHandler: input)
    }
}
