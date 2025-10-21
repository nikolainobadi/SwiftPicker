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

    @Test("Completes without selections when user confirms immediately")
    func completesWithoutSelectionsWhenUserConfirmsImmediately() {
        let input = MockInput(screenSize: (26, 100), directionKey: nil)
        let handler = makeSUT(items: makeItems(), input: input)

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)

        let result = handler.captureUserInput()

        #expect(result.isEmpty)
    }

    @Test("Captures multiple selections with spacebar and down navigation")
    func capturesMultipleSelectionsWithSpacebarAndDownNavigation() {
        let selectionCount = 6
        let input = MockInput(screenSize: (26, 100), directionKey: .down)
        let handler = makeSUT(items: makeItems(), input: input)

        input.pressKey = true

        for _ in 0..<selectionCount {
            input.enqueueSpecialChar(specialChar: .space)
        }

        input.enqueueSpecialChar(specialChar: .enter)

        let result = handler.captureUserInput()

        #expect(result.count == selectionCount)
    }
}

// MARK: - Navigation Boundary Tests
extension MultiSelectionTests {
    @Test("Prevents navigation above first option with up arrow")
    func preventsNavigationAboveFirstOptionWithUpArrow() {
        let input = MockInput(screenSize: (26, 100), directionKey: .up)
        let handler = makeSUT(items: makeItems(), input: input)
        let state = handler.state
        let topLineLimit = PickerPadding.top

        input.pressKey = true

        #expect(state.activeLine == topLineLimit)
        for _ in 0..<5 {
            input.enqueueSpecialChar(specialChar: nil)
        }
        input.enqueueSpecialChar(specialChar: .enter)

        let _ = handler.captureUserInput()

        #expect(state.activeLine == topLineLimit)
    }

    @Test("Allows navigation through all available options")
    func allowsNavigationThroughAllAvailableOptions() {
        let itemCount = 25
        let items = makeItems(itemCount: itemCount)
        let directionCount = itemCount
        let input = MockInput(screenSize: (26, 100), directionKey: .down)
        let handler = makeSUT(items: items, input: input)
        let state = handler.state
        let bottomLineLimit = itemCount + PickerPadding.top

        input.pressKey = true

        for _ in 0..<directionCount {
            input.enqueueSpecialChar(specialChar: nil)
        }
        input.enqueueSpecialChar(specialChar: .enter)

        let _ = handler.captureUserInput()

        #expect(state.activeLine == bottomLineLimit)
    }

    @Test("Prevents navigation beyond last option with down arrow")
    func preventsNavigationBeyondLastOptionWithDownArrow() {
        let itemCount = 25
        let items = makeItems(itemCount: itemCount)
        let directionCount = 30
        let input = MockInput(screenSize: (26, 100), directionKey: .down)
        let handler = makeSUT(items: items, input: input)
        let state = handler.state
        let bottomLineLimit = itemCount + PickerPadding.top

        input.pressKey = true

        for _ in 0..<directionCount {
            input.enqueueSpecialChar(specialChar: nil)
        }
        input.enqueueSpecialChar(specialChar: .enter)

        let _ = handler.captureUserInput()

        #expect(state.activeLine == bottomLineLimit)
    }
}

// MARK: - SUT
private extension MultiSelectionTests {
    func makeSUT(items: [String], input: MockInput, title: String = "Test Selection") -> MultiSelectionHandler<String> {
        let info = PickerInfo(title: title, items: items)

        return SelectionHandlerFactory.makeMultiSelectionHandler(info: info, newScreen: false, inputHandler: input)
    }
}
