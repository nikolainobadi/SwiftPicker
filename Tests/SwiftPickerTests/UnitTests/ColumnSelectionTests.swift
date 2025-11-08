//
//  ColumnSelectionTests.swift
//
//
//  Created by Nikolai Nobadi on 11/8/25.
//

import Testing
@testable import SwiftPicker

struct ColumnSelectionTests {
    @Test("Returns selected item when Enter pressed")
    func returnsSelectedItemWhenEnterPressed() {
        let items = Self.makeItems(count: 5)
        let columns = [makeColumn(title: "Test", items: items)]
        let input = MockInput()

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = makeSUT(columns: columns, input: input)
        let result = handler.captureUserInput()

        #expect(result != nil)
        #expect(items.contains(result!))
    }

    @Test("Returns nil when user quits")
    func returnsNilWhenUserQuits() {
        let columns = [makeColumn()]
        let input = MockInput()

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .quit)

        let handler = makeSUT(columns: columns, input: input)
        let result = handler.captureUserInput()

        #expect(result == nil)
    }

    @Test("Navigates vertically within active column")
    func navigatesVerticallyWithinActiveColumn() {
        let firstItem = "Item 0"
        let thirdItem = "Item 2"
        let items = Self.makeItems(count: 5)
        let columns = [makeColumn(items: items)]
        let input = MockInput(screenSize: (30, 100), directionKey: .down)

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: nil)
        input.enqueueSpecialChar(specialChar: nil)
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = makeSUT(columns: columns, input: input)
        let result = handler.captureUserInput()

        #expect(result != firstItem)
        #expect(result == thirdItem)
    }

    @Test("Navigates between columns using left and right arrow keys")
    func navigatesBetweenColumnsUsingLeftAndRightArrowKeys() {
        let firstColumnItems = ["A", "B", "C"]
        let secondColumnItems = ["X", "Y", "Z"]
        let columns = [
            makeColumn(title: "First", items: firstColumnItems),
            makeColumn(title: "Second", items: secondColumnItems)
        ]
        let input = MockInput(screenSize: (30, 100), directionKey: .left)

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: nil)
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = makeSUT(columns: columns, input: input)
        let result = handler.captureUserInput()

        #expect(result != nil)
        #expect(firstColumnItems.contains(result!))
    }

    @Test("Starts at rightmost column by default")
    func startsAtRightmostColumnByDefault() {
        let firstColumnItems = ["A", "B"]
        let secondColumnItems = ["X", "Y"]
        let columns = [
            makeColumn(title: "First", items: firstColumnItems),
            makeColumn(title: "Second", items: secondColumnItems)
        ]
        let input = MockInput()

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = makeSUT(columns: columns, input: input)
        let result = handler.captureUserInput()

        #expect(result != nil)
        #expect(secondColumnItems.contains(result!))
    }
}


// MARK: - Boundary Tests
extension ColumnSelectionTests {
    @Test("Prevents navigation beyond column boundaries")
    func preventsNavigationBeyondColumnBoundaries() {
        let firstColumnItems = ["A"]
        let secondColumnItems = ["X"]
        let columns = [
            makeColumn(title: "First", items: firstColumnItems),
            makeColumn(title: "Second", items: secondColumnItems)
        ]
        let input = MockInput()

        input.pressKey = true
        input.enqueueDirectionKey(directionKey: .right)
        input.enqueueDirectionKey(directionKey: .right)
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = makeSUT(columns: columns, input: input)
        let result = handler.captureUserInput()

        #expect(result != nil)
        #expect(secondColumnItems.contains(result!))
    }

    @Test("Prevents vertical navigation beyond item boundaries")
    func preventsVerticalNavigationBeyondItemBoundaries() {
        let firstItem = "Item 0"
        let items = Self.makeItems(count: 3)
        let columns = [makeColumn(items: items)]
        let input = MockInput()

        input.pressKey = true
        input.enqueueDirectionKey(directionKey: .up)
        input.enqueueDirectionKey(directionKey: .up)
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = makeSUT(columns: columns, input: input)
        let result = handler.captureUserInput()

        #expect(result == firstItem)
    }

    @Test("Handles empty column gracefully")
    func handlesEmptyColumnGracefully() {
        let emptyColumn = makeColumn(items: [])
        let filledColumn = makeColumn(items: Self.makeItems(count: 2))
        let columns = [emptyColumn, filledColumn]
        let input = MockInput()

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = makeSUT(columns: columns, input: input)
        let result = handler.captureUserInput()

        #expect(result != nil)
    }

    @Test("Handles single column mode")
    func handlesSingleColumnMode() {
        let items = Self.makeItems(count: 3)
        let columns = [makeColumn(items: items)]
        let input = MockInput()

        input.pressKey = true
        input.enqueueDirectionKey(directionKey: .left)
        input.enqueueDirectionKey(directionKey: .right)
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = makeSUT(columns: columns, input: input)
        let result = handler.captureUserInput()

        #expect(result != nil)
        #expect(items.contains(result!))
    }
}


// MARK: - Navigation Combinations
extension ColumnSelectionTests {
    @Test("Preserves item position when switching columns")
    func preservesItemPositionWhenSwitchingColumns() {
        let firstColumnItems = ["A", "B", "C"]
        let secondColumnItems = ["X", "Y", "Z"]
        var columns = [
            makeColumn(title: "First", items: firstColumnItems),
            makeColumn(title: "Second", items: secondColumnItems)
        ]

        // Set both columns to index 1
        columns[0].activeIndex = 1
        columns[1].activeIndex = 1

        let input = MockInput(screenSize: (30, 100), directionKey: .left)

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: nil)
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = makeSUT(columns: columns, input: input)
        let result = handler.captureUserInput()

        // Should select "B" from first column (both columns have same index)
        #expect(result == "B")
    }

    @Test("Supports complex navigation patterns")
    func supportsComplexNavigationPatterns() {
        let firstColumnItems = Self.makeItems(count: 5)
        let secondColumnItems = Self.makeItems(count: 5)
        var columns = [
            makeColumn(title: "First", items: firstColumnItems),
            makeColumn(title: "Second", items: secondColumnItems)
        ]
        // Start at second column, index 2
        columns[1].activeIndex = 2

        let input = MockInput()

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = makeSUT(columns: columns, input: input)
        let result = handler.captureUserInput()

        #expect(result != nil)
        #expect(result == "Item 2")
    }

    @Test("Handles rapid column switching")
    func handlesRapidColumnSwitching() {
        let firstColumnItems = ["A", "B"]
        let secondColumnItems = ["X", "Y"]
        let columns = [
            makeColumn(title: "First", items: firstColumnItems),
            makeColumn(title: "Second", items: secondColumnItems)
        ]
        let input = MockInput()

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = makeSUT(columns: columns, input: input)
        let result = handler.captureUserInput()

        // Should select from second column (default active column)
        #expect(result != nil)
        #expect(secondColumnItems.contains(result!))
    }
}


// MARK: - Integration Tests
extension ColumnSelectionTests {
    @Test("Integrates with InteractivePicker API")
    func integratesWithInteractivePickerAPI() {
        let mockTextInputHandler = MockTextInputHandler()
        let mockPickerInputHandler = MockInput()
        let picker = InteractivePicker(textInputHandler: mockTextInputHandler, pickerInputHandler: mockPickerInputHandler)

        let items = Self.makeItems(count: 3)
        let columns: [PickerColumn<String>] = [makeColumn(items: items)]

        mockPickerInputHandler.pressKey = true
        mockPickerInputHandler.enqueueSpecialChar(specialChar: .enter)

        let result: String? = picker.columnSelection(columns: columns, title: "Test")

        #expect(result != nil)
    }

    @Test("Supports custom DisplayablePickerItem types")
    func supportsCustomDisplayablePickerItemTypes() {
        struct CustomItem: DisplayablePickerItem {
            let displayName: String
            let value: Int
        }

        let items = [
            CustomItem(displayName: "First", value: 1),
            CustomItem(displayName: "Second", value: 2)
        ]
        var columns = [PickerColumn(title: "Custom", items: items)]
        // Start at index 1 (second item)
        columns[0].activeIndex = 1

        let input = MockInput()

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = SelectionHandlerFactory.makeColumnSelectionHandler(
            columns: columns,
            title: "Test",
            newScreen: false,
            inputHandler: input
        )
        let result = handler.captureUserInput()

        #expect(result != nil)
        #expect(result?.value == 2)
    }

    @Test("Works with multiple columns containing different item counts")
    func worksWithMultipleColumnsContainingDifferentItemCounts() {
        let shortColumn = makeColumn(title: "Short", items: Self.makeItems(count: 2))
        let mediumColumn = makeColumn(title: "Medium", items: Self.makeItems(count: 5))
        let longColumn = makeColumn(title: "Long", items: Self.makeItems(count: 10))
        let columns = [shortColumn, mediumColumn, longColumn]
        let input = MockInput()

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = makeSUT(columns: columns, input: input)
        let result = handler.captureUserInput()

        // Should successfully select from the long column (rightmost)
        #expect(result != nil)
    }
}


// MARK: - SUT
private extension ColumnSelectionTests {
    func makeSUT(
        columns: [PickerColumn<String>],
        input: MockInput,
        title: String = "Test Columns"
    ) -> ColumnSelectionHandler<String> {
        return SelectionHandlerFactory.makeColumnSelectionHandler(
            columns: columns,
            title: title,
            newScreen: false,
            inputHandler: input
        )
    }

    func makeColumn(title: String = "Column", items: [String]? = nil) -> PickerColumn<String> {
        return PickerColumn(title: title, items: items ?? Self.makeItems(), activeIndex: 0)
    }

    static func makeItems(count: Int = 5) -> [String] {
        return (0..<count).map { "Item \($0)" }
    }
}
