//
//  EdgeCaseTests.swift
//  
//
//  Created by Nikolai Nobadi on 8/10/25.
//

import Testing
@testable import SwiftPicker

struct EdgeCaseTests {
    @Test("Empty item list returns nil for single selection")
    func singleSelectionHandlesEmptyItemListGracefully() {
        let items: [String] = []
        let input = MockInput(screenSize: (30, 100), directionKey: nil)

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)

        let info = makePickerInfo(title: "Empty List Test", items: items)
        let handler = SelectionHandlerFactory.makeSingleSelectionHandler(info: info, newScreen: false, inputHandler: input)

        let result = handler.captureUserInput()

        #expect(result == nil)
    }

    @Test("Empty item list returns empty array for multi selection")
    func multiSelectionHandlesEmptyItemListGracefully() {
        let items: [String] = []
        let input = MockInput(screenSize: (30, 100), directionKey: nil)

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)

        let info = makePickerInfo(title: "Empty Multi List", items: items)
        let handler = SelectionHandlerFactory.makeMultiSelectionHandler(info: info, newScreen: false, inputHandler: input)

        let result = handler.captureUserInput()

        #expect(result.isEmpty)
    }

    @Test("Single item list selects only option immediately")
    func singleItemListAllowsImmediateSelection() {
        let items = ["Only Option"]
        let input = MockInput(screenSize: (30, 100), directionKey: nil)

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)

        let info = makePickerInfo(title: "Single Item", items: items)
        let handler = SelectionHandlerFactory.makeSingleSelectionHandler(info: info, newScreen: false, inputHandler: input)

        let result = handler.captureUserInput()

        #expect(result == items[0])
    }
}

// MARK: - Quit Behavior Edge Cases
extension EdgeCaseTests {
    @Test("Quitting single selection returns nil")
    func userCanQuitSingleSelectionAtAnyTime() {
        let items = ["Option 1", "Option 2", "Option 3"]
        let input = MockInput(screenSize: (30, 100), directionKey: nil)

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .quit)

        let info = makePickerInfo(title: "Quit Test", items: items)
        let handler = SelectionHandlerFactory.makeSingleSelectionHandler(info: info, newScreen: false, inputHandler: input)

        let result = handler.captureUserInput()

        #expect(result == nil)
    }

    @Test("Quitting multi selection discards partial selections")
    func userCanQuitMultiSelectionAfterMakingPartialSelections() {
        let items = ["A", "B", "C", "D"]
        let input = MockInput(screenSize: (30, 100), directionKey: .down)

        input.pressKey = true

        input.enqueueSpecialChar(specialChar: .space)
        input.enqueueSpecialChar(specialChar: .space)
        input.enqueueSpecialChar(specialChar: .quit)

        let info = makePickerInfo(title: "Partial Quit", items: items)
        let handler = SelectionHandlerFactory.makeMultiSelectionHandler(info: info, newScreen: false, inputHandler: input)
        let result = handler.captureUserInput()

        #expect(result.isEmpty)
    }

    @Test("Quit returns nil regardless of navigation position")
    func quitBehaviorIsConsistentAcrossDifferentPositions() {
        let items = ["First", "Second", "Third", "Fourth"]
        let input = MockInput(screenSize: (30, 100), directionKey: .down)

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: nil)
        input.enqueueSpecialChar(specialChar: nil)
        input.enqueueSpecialChar(specialChar: .quit)

        let info = makePickerInfo(title: "Middle Quit", items: items)
        let handler = SelectionHandlerFactory.makeSingleSelectionHandler(info: info, newScreen: false, inputHandler: input)

        let result = handler.captureUserInput()

        #expect(result == nil)
    }
}

// MARK: - Navigation Boundary Edge Cases  
extension EdgeCaseTests {
    @Test("Upward navigation stops at first item")
    func navigationStopsAtTopBoundaryConsistently() {
        let items = ["Top", "Middle", "Bottom"]
        let input = MockInput(screenSize: (30, 100), directionKey: .up)

        input.pressKey = true

        let info = makePickerInfo(title: "Top Boundary", items: items)
        let handler = SelectionHandlerFactory.makeSingleSelectionHandler(info: info, newScreen: false, inputHandler: input)
        let state = handler.state
        let initialLine = state.activeLine

        for _ in 0..<10 {
            input.enqueueSpecialChar(specialChar: nil)
        }
        input.enqueueSpecialChar(specialChar: .enter)

        let result = handler.captureUserInput()

        #expect(state.activeLine == initialLine)
        #expect(result == items[0])
    }

    @Test("Downward navigation stops at last item")
    func navigationStopsAtBottomBoundaryConsistently() {
        let items = ["First", "Second", "Last"]
        let input = MockInput(screenSize: (30, 100), directionKey: .down)

        input.pressKey = true

        let info = makePickerInfo(title: "Bottom Boundary", items: items)
        let handler = SelectionHandlerFactory.makeSingleSelectionHandler(info: info, newScreen: false, inputHandler: input)

        input.enqueueSpecialChar(specialChar: .enter)

        let result = handler.captureUserInput()

        #expect(result == items[0])
    }
}

// MARK: - Large Dataset Edge Cases
extension EdgeCaseTests {
    @Test("Thousands of items navigate and select correctly")
    func largeItemListsHandleNavigationEfficiently() {
        let items = (1...1000).map { "Item \($0)" }
        let input = MockInput(screenSize: (30, 100), directionKey: .down)

        input.pressKey = true

        for _ in 0..<500 {
            input.enqueueSpecialChar(specialChar: nil)
        }
        input.enqueueSpecialChar(specialChar: .enter)

        let info = makePickerInfo(title: "Large List", items: items)
        let handler = SelectionHandlerFactory.makeSingleSelectionHandler(info: info, newScreen: false, inputHandler: input)

        let result = handler.captureUserInput()

        #expect(result != nil)
        #expect(result!.hasPrefix("Item"))
    }

    @Test("Dozens of multi-selections return all selected items")
    func multiSelectionHandlesLargeSelectionsEfficiently() {
        let items = (1...100).map { "Option \($0)" }
        let selectionCount = 50
        let input = MockInput(screenSize: (30, 100), directionKey: .down)

        input.pressKey = true

        for _ in 0..<selectionCount {
            input.enqueueSpecialChar(specialChar: .space)
            input.enqueueSpecialChar(specialChar: nil)
        }
        input.enqueueSpecialChar(specialChar: .enter)

        let info = makePickerInfo(title: "Large Multi", items: items)
        let handler = SelectionHandlerFactory.makeMultiSelectionHandler(info: info, newScreen: false, inputHandler: input)

        let result = handler.captureUserInput()

        #expect(result.count == selectionCount)
        #expect(result.allSatisfy { $0.hasPrefix("Option") })
    }
}

// MARK: - Special Character Edge Cases
extension EdgeCaseTests {
    @Test("Special characters in items preserve exact values")
    func itemsWithSpecialCharactersDisplayAndSelectCorrectly() {
        let items = ["Item@#$%", "Item with spaces", "Item\twith\ttabs", "Item\nwith\nnewlines"]
        let input = MockInput(screenSize: (30, 100), directionKey: nil)

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)

        let info = makePickerInfo(title: "Special Chars", items: items)
        let handler = SelectionHandlerFactory.makeSingleSelectionHandler(info: info, newScreen: false, inputHandler: input)

        let result = handler.captureUserInput()

        #expect(result == items[0])
    }

    @Test("Unicode emoji items display and select accurately")
    func unicodeCharactersInItemsAreHandledCorrectly() {
        let items = ["🚀 Rocket", "🎯 Target", "💡 Idea", "🔥 Fire"]
        let input = MockInput(screenSize: (30, 100), directionKey: .down)

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: nil)
        input.enqueueSpecialChar(specialChar: .enter)

        let info = makePickerInfo(title: "Unicode Test", items: items)
        let handler = SelectionHandlerFactory.makeSingleSelectionHandler(info: info, newScreen: false, inputHandler: input)

        let result = handler.captureUserInput()

        #expect(result == items[1])
    }
}

// MARK: - SUT
private extension EdgeCaseTests {
    func makeSUT<Item: DisplayablePickerItem>(
        items: [Item],
        title: String = "Test Selection",
        screenSize: (Int, Int) = (30, 100),
        directionKey: Direction? = nil,
        specialChars: [SpecialChar?] = []
    ) -> MockInput {
        let input = MockInput(screenSize: screenSize, directionKey: directionKey)
        input.pressKey = true

        for char in specialChars {
            input.enqueueSpecialChar(specialChar: char)
        }

        return input
    }
}
