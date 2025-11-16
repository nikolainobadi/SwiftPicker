//
//  DualColumnSelectionTests.swift
//
//
//  Created by Nikolai Nobadi on 11/13/25.
//

import Testing
@testable import SwiftPicker

struct DualColumnSelectionTests {
    @Test("Starts at first column by default")
    func startsAtFirstColumnByDefault() {
        let selectableItems = ["Option A", "Option B", "Option C"]
        let displayItems = ["Info 1", "Info 2", "Info 3"]
        let input = MockInput()

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = makeSUT(selectableItems: selectableItems, displayItems: displayItems, input: input)
        let result = handler.captureUserInput()

        #expect(result != nil)
        #expect(selectableItems.contains(result!))
    }

    @Test("Returns selected item from selectable column when Enter pressed")
    func returnsSelectedItemFromSelectableColumnWhenEnterPressed() {
        let selectedItem = "Option B"
        let selectableItems = ["Option A", selectedItem, "Option C"]
        let displayItems = ["Info 1", "Info 2", "Info 3"]
        var selectableColumn = makeColumn(title: "Options", items: selectableItems, isSelectable: true)
        selectableColumn.activeIndex = 1

        let input = MockInput()
        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = makeSUT(selectableColumn: selectableColumn, displayColumn: makeColumn(title: "Info", items: displayItems, isSelectable: false), input: input)
        let result = handler.captureUserInput()

        #expect(result == selectedItem)
    }

    @Test("Returns nil when user quits")
    func returnsNilWhenUserQuits() {
        let selectableItems = ["Option A", "Option B"]
        let displayItems = ["Info 1", "Info 2"]
        let input = MockInput()

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .quit)

        let handler = makeSUT(selectableItems: selectableItems, displayItems: displayItems, input: input)
        let result = handler.captureUserInput()

        #expect(result == nil)
    }

    @Test("Navigates vertically within selectable column")
    func navigatesVerticallyWithinSelectableColumn() {
        let firstItem = "Option A"
        let thirdItem = "Option C"
        let selectableItems = [firstItem, "Option B", thirdItem]
        let displayItems = ["Info 1", "Info 2", "Info 3"]
        let input = MockInput(directionKey: .down)

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: nil)
        input.enqueueSpecialChar(specialChar: nil)
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = makeSUT(selectableItems: selectableItems, displayItems: displayItems, input: input)
        let result = handler.captureUserInput()

        #expect(result != firstItem)
        #expect(result == thirdItem)
    }

    @Test("Navigates vertically within display column")
    func navigatesVerticallyWithinDisplayColumn() {
        let selectableItems = ["Option A"]
        let displayItems = ["Info 1", "Info 2", "Info 3"]
        let input = MockInput(directionKey: .down)

        input.pressKey = true
        input.enqueueDirectionKey(directionKey: .right)
        input.enqueueSpecialChar(specialChar: nil)
        input.enqueueSpecialChar(specialChar: nil)
        input.enqueueSpecialChar(specialChar: nil)
        input.enqueueDirectionKey(directionKey: .left)
        input.enqueueSpecialChar(specialChar: nil)
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = makeSUT(selectableItems: selectableItems, displayItems: displayItems, input: input)
        let result = handler.captureUserInput()

        #expect(result != nil)
        #expect(selectableItems.contains(result!))
    }
}


// MARK: - Column Switching Tests
extension DualColumnSelectionTests {
    @Test("Switches from selectable to display column using right arrow")
    func switchesFromSelectableToDisplayColumnUsingRightArrow() {
        let selectableItems = ["Option A", "Option B"]
        let displayItems = ["Info 1", "Info 2"]
        let input = MockInput()

        input.pressKey = true
        input.enqueueDirectionKey(directionKey: .right)
        input.enqueueSpecialChar(specialChar: nil)
        input.enqueueSpecialChar(specialChar: .enter)
        input.enqueueSpecialChar(specialChar: .quit)

        let handler = makeSUT(selectableItems: selectableItems, displayItems: displayItems, input: input)
        let result = handler.captureUserInput()

        #expect(result == nil)
    }

    @Test("Prevents navigation beyond column boundaries")
    func preventsNavigationBeyondColumnBoundaries() {
        let selectableItems = ["Option A"]
        let displayItems = ["Info 1"]
        let input = MockInput()

        input.pressKey = true
        input.enqueueDirectionKey(directionKey: .left)
        input.enqueueDirectionKey(directionKey: .left)
        input.enqueueSpecialChar(specialChar: nil)
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = makeSUT(selectableItems: selectableItems, displayItems: displayItems, input: input)
        let result = handler.captureUserInput()

        #expect(result != nil)
        #expect(selectableItems.contains(result!))
    }
}


// MARK: - Selectability Tests
extension DualColumnSelectionTests {
    @Test("Ignores Enter key press on display column")
    func ignoresEnterKeyPressOnDisplayColumn() {
        let selectableItems = ["Option A", "Option B"]
        let displayItems = ["Info 1", "Info 2"]
        let input = MockInput()

        input.pressKey = true
        input.enqueueDirectionKey(directionKey: .right)
        input.enqueueSpecialChar(specialChar: nil)
        input.enqueueSpecialChar(specialChar: .enter)
        input.enqueueSpecialChar(specialChar: .quit)

        let handler = makeSUT(selectableItems: selectableItems, displayItems: displayItems, input: input)
        let result = handler.captureUserInput()

        #expect(result == nil)
    }

    @Test("Allows Enter key press on selectable column")
    func allowsEnterKeyPressOnSelectableColumn() {
        let selectableItems = ["Option A", "Option B"]
        let displayItems = ["Info 1", "Info 2"]
        let input = MockInput()

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = makeSUT(selectableItems: selectableItems, displayItems: displayItems, input: input)
        let result = handler.captureUserInput()

        #expect(result != nil)
        #expect(selectableItems.contains(result!))
    }

    @Test("Display column remains static regardless of selectable column navigation")
    func displayColumnRemainsStaticRegardlessOfSelectableColumnNavigation() {
        let selectableItems = ["Option A", "Option B", "Option C"]
        let displayItems = ["Info 1", "Info 2", "Info 3"]
        let input = MockInput(directionKey: .down)

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: nil)
        input.enqueueSpecialChar(specialChar: nil)
        input.enqueueDirectionKey(directionKey: .right)
        input.enqueueSpecialChar(specialChar: nil)
        input.enqueueSpecialChar(specialChar: .enter)
        input.enqueueSpecialChar(specialChar: .quit)

        let handler = makeSUT(selectableItems: selectableItems, displayItems: displayItems, input: input)
        let result = handler.captureUserInput()

        #expect(result == nil)
    }
}


// MARK: - Space and Backspace Tests
extension DualColumnSelectionTests {
    @Test("Ignores space key press in dual-column mode")
    func ignoresSpaceKeyPressInDualColumnMode() {
        let selectableItems = ["Option A", "Option B"]
        let displayItems = ["Info 1", "Info 2"]
        let input = MockInput()

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .space)
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = makeSUT(selectableItems: selectableItems, displayItems: displayItems, input: input)
        let result = handler.captureUserInput()

        #expect(result != nil)
        #expect(selectableItems.contains(result!))
    }

    @Test("Ignores backspace key press in dual-column mode")
    func ignoresBackspaceKeyPressInDualColumnMode() {
        let selectableItems = ["Option A", "Option B"]
        let displayItems = ["Info 1", "Info 2"]
        let input = MockInput()

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .backspace)
        input.enqueueSpecialChar(specialChar: .backspace)
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = makeSUT(selectableItems: selectableItems, displayItems: displayItems, input: input)
        let result = handler.captureUserInput()

        #expect(result != nil)
        #expect(selectableItems.contains(result!))
    }
}


// MARK: - Integration Tests
extension DualColumnSelectionTests {
    @Test("Integrates with InteractivePicker API")
    func integratesWithInteractivePickerAPI() {
        let mockTextInputHandler = MockTextInputHandler()
        let mockPickerInputHandler = MockInput()
        let picker = InteractivePicker(textInputHandler: mockTextInputHandler, pickerInputHandler: mockPickerInputHandler)

        let selectableItems = ["Option A", "Option B", "Option C"]
        let instructions = "Select an option from the list"

        mockPickerInputHandler.pressKey = true
        mockPickerInputHandler.enqueueSpecialChar(specialChar: .enter)

        let result: String? = picker.singleSelectStaticDetailColumnSelection(
            selectableItems: selectableItems,
            instructions: instructions,
            selectableTitle: "Options",
            instructionsTitle: "Information",
            title: "Test Dual Column"
        )

        #expect(result != nil)
        #expect(selectableItems.contains(result!))
    }

    @Test("Supports custom DisplayablePickerItem types")
    func supportsCustomDisplayablePickerItemTypes() {
        struct CustomItem: DisplayablePickerItem {
            let displayName: String
            let value: Int
        }

        let selectableItems = [
            CustomItem(displayName: "First", value: 1),
            CustomItem(displayName: "Second", value: 2)
        ]
        let displayItems = [
            CustomItem(displayName: "Info A", value: 100),
            CustomItem(displayName: "Info B", value: 200)
        ]

        var selectableColumn = PickerColumn(title: "Options", items: selectableItems, activeIndex: 1, isSelectable: true)
        selectableColumn.activeIndex = 1

        let input = MockInput()
        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = SelectionHandlerFactory.makeDualColumnSelectionHandler(
            selectableColumn: selectableColumn,
            displayColumn: PickerColumn(title: "Info", items: displayItems, isSelectable: false),
            title: "Test",
            newScreen: false,
            inputHandler: input
        )
        let result = handler.captureUserInput()

        #expect(result != nil)
        #expect(result?.value == 2)
    }

    @Test("Works with different item counts in each column")
    func worksWithDifferentItemCountsInEachColumn() {
        let selectableItems = ["A", "B"]
        let displayItems = ["Info 1", "Info 2", "Info 3", "Info 4", "Info 5"]
        let input = MockInput()

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = makeSUT(selectableItems: selectableItems, displayItems: displayItems, input: input)
        let result = handler.captureUserInput()

        #expect(result != nil)
        #expect(selectableItems.contains(result!))
    }

    @Test("Handles empty display column gracefully")
    func handlesEmptyDisplayColumnGracefully() {
        let selectableItems = ["Option A", "Option B"]
        let displayItems: [String] = []
        let input = MockInput()

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = makeSUT(selectableItems: selectableItems, displayItems: displayItems, input: input)
        let result = handler.captureUserInput()

        #expect(result != nil)
        #expect(selectableItems.contains(result!))
    }
}


// MARK: - Factory Method Tests
extension DualColumnSelectionTests {
    @Test("Factory method enforces first column as selectable")
    func factoryMethodEnforcesFirstColumnAsSelectable() {
        let selectableItems = ["A", "B"]
        let displayItems = ["X", "Y"]
        let selectableColumn = PickerColumn(title: "Options", items: selectableItems, isSelectable: false)
        let displayColumn = PickerColumn(title: "Info", items: displayItems, isSelectable: true)

        let input = MockInput()
        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = SelectionHandlerFactory.makeDualColumnSelectionHandler(
            selectableColumn: selectableColumn,
            displayColumn: displayColumn,
            title: "Test",
            newScreen: false,
            inputHandler: input
        )
        let result = handler.captureUserInput()

        #expect(result != nil)
        #expect(selectableItems.contains(result!))
    }

    @Test("Factory method enforces second column as non-selectable")
    func factoryMethodEnforcesSecondColumnAsNonSelectable() {
        let selectableItems = ["A", "B"]
        let displayItems = ["X", "Y"]
        let selectableColumn = PickerColumn(title: "Options", items: selectableItems, isSelectable: true)
        let displayColumn = PickerColumn(title: "Info", items: displayItems, isSelectable: true)

        let input = MockInput()
        input.pressKey = true
        input.enqueueDirectionKey(directionKey: .right)
        input.enqueueSpecialChar(specialChar: nil)
        input.enqueueSpecialChar(specialChar: .enter)
        input.enqueueSpecialChar(specialChar: .quit)

        let handler = SelectionHandlerFactory.makeDualColumnSelectionHandler(
            selectableColumn: selectableColumn,
            displayColumn: displayColumn,
            title: "Test",
            newScreen: false,
            inputHandler: input
        )
        let result = handler.captureUserInput()

        #expect(result == nil)
    }
}


// MARK: - SUT
private extension DualColumnSelectionTests {
    func makeSUT(
        selectableItems: [String],
        displayItems: [String],
        input: MockInput,
        title: String = "Dual Column Test"
    ) -> ColumnSelectionHandler<String> {
        let selectableColumn = makeColumn(title: "Selectable", items: selectableItems, isSelectable: true)
        let displayColumn = makeColumn(title: "Display", items: displayItems, isSelectable: false)

        return makeSUT(selectableColumn: selectableColumn, displayColumn: displayColumn, input: input, title: title)
    }

    func makeSUT(
        selectableColumn: PickerColumn<String>,
        displayColumn: PickerColumn<String>,
        input: MockInput,
        title: String = "Dual Column Test"
    ) -> ColumnSelectionHandler<String> {
        return SelectionHandlerFactory.makeDualColumnSelectionHandler(
            selectableColumn: selectableColumn,
            displayColumn: displayColumn,
            title: title,
            newScreen: false,
            inputHandler: input
        )
    }

    func makeColumn(title: String, items: [String], isSelectable: Bool) -> PickerColumn<String> {
        return PickerColumn(title: title, items: items, activeIndex: 0, isSelectable: isSelectable)
    }
}
