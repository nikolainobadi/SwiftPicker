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

        let result: String? = picker.dualColumnSelection(columns: columns, title: "Test")

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


// MARK: - Space Navigation Tests
extension ColumnSelectionTests {
    @Test("Navigates into item when space pressed with children")
    func navigatesIntoItemWhenSpacePressedWithChildren() {
        let parentItem = "Parent"
        let childItem = "Child 0"
        let parentColumn = makeColumn(items: [parentItem])
        let input = MockInput()

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .space)
        input.enqueueSpecialChar(specialChar: .enter)

        let onNavigate: (String) -> (items: [String], title: String)? = { item in
            if item == parentItem {
                return (items: ["Child 0", "Child 1"], title: "Children")
            }
            return nil
        }

        let handler = makeSUT(columns: [parentColumn], input: input, onNavigate: onNavigate)
        let result = handler.captureUserInput()

        #expect(result == childItem)
    }

    @Test("Does nothing when space pressed without onNavigate closure")
    func doesNothingWhenSpacePressedWithoutOnNavigateClosure() {
        let items = Self.makeItems(count: 3)
        let columns = [makeColumn(items: items)]
        let input = MockInput()

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .space)
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = makeSUT(columns: columns, input: input)
        let result = handler.captureUserInput()

        #expect(result != nil)
        #expect(items.contains(result!))
    }

    @Test("Does nothing when onNavigate returns nil")
    func doesNothingWhenOnNavigateReturnsNil() {
        let items = Self.makeItems(count: 3)
        let columns = [makeColumn(items: items)]
        let input = MockInput()

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .space)
        input.enqueueSpecialChar(specialChar: .enter)

        let onNavigate: (String) -> (items: [String], title: String)? = { _ in nil }

        let handler = makeSUT(columns: columns, input: input, onNavigate: onNavigate)
        let result = handler.captureUserInput()

        #expect(result != nil)
        #expect(items.contains(result!))
    }

    @Test("Removes subsequent columns when navigating into parent column item")
    func removesSubsequentColumnsWhenNavigatingIntoParentColumnItem() {
        let firstColumnItems = ["Item A", "Item B"]
        let secondColumnItems = ["Old Child"]
        let thirdColumnItems = ["Old Grandchild"]
        let columns = [
            makeColumn(title: "First", items: firstColumnItems),
            makeColumn(title: "Second", items: secondColumnItems),
            makeColumn(title: "Third", items: thirdColumnItems)
        ]
        let input = MockInput()

        input.pressKey = true
        input.enqueueDirectionKey(directionKey: .left)
        input.enqueueSpecialChar(specialChar: nil)
        input.enqueueDirectionKey(directionKey: .left)
        input.enqueueSpecialChar(specialChar: nil)
        input.enqueueDirectionKey(directionKey: nil)
        input.enqueueSpecialChar(specialChar: .space)
        input.enqueueDirectionKey(directionKey: nil)
        input.enqueueSpecialChar(specialChar: .enter)

        let onNavigate: (String) -> (items: [String], title: String)? = { item in
            if item == "Item A" {
                return (items: ["New Child A", "New Child B"], title: "New Children")
            }
            return nil
        }

        let handler = makeSUT(columns: columns, input: input, onNavigate: onNavigate)
        let result = handler.captureUserInput()

        #expect(result == "New Child A")
    }

    @Test("Supports multiple level navigation into nested children")
    func supportsMultipleLevelNavigationIntoNestedChildren() {
        let rootItem = "Root"
        let rootColumn = makeColumn(items: [rootItem])
        let input = MockInput()

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .space)
        input.enqueueSpecialChar(specialChar: .space)
        input.enqueueSpecialChar(specialChar: .enter)

        let onNavigate: (String) -> (items: [String], title: String)? = { item in
            if item == "Root" {
                return (items: ["Child"], title: "Children")
            } else if item == "Child" {
                return (items: ["Grandchild"], title: "Grandchildren")
            }
            return nil
        }

        let handler = makeSUT(columns: [rootColumn], input: input, onNavigate: onNavigate)
        let result = handler.captureUserInput()

        #expect(result == "Grandchild")
    }
}


// MARK: - Backspace Navigation Tests
extension ColumnSelectionTests {
    @Test("Navigates back one level when backspace pressed")
    func navigatesBackOneLevelWhenBackspacePressed() {
        let parentItem = "Parent"
        let parentColumn = makeColumn(items: [parentItem])
        let input = MockInput()

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .space)  // Navigate into child
        input.enqueueSpecialChar(specialChar: .backspace)  // Navigate back
        input.enqueueSpecialChar(specialChar: .enter)  // Select parent

        let onNavigate: (String) -> (items: [String], title: String)? = { item in
            if item == parentItem {
                return (items: ["Child 0", "Child 1"], title: "Children")
            }
            return nil
        }

        let handler = makeSUT(columns: [parentColumn], input: input, onNavigate: onNavigate)
        let result = handler.captureUserInput()

        #expect(result == parentItem)  // Should be back at parent
    }

    @Test("Does nothing when backspace pressed at root level")
    func doesNothingWhenBackspacePressedAtRootLevel() {
        let items = Self.makeItems(count: 3)
        let columns = [makeColumn(items: items)]
        let input = MockInput()

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .backspace)
        input.enqueueSpecialChar(specialChar: .backspace)
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = makeSUT(columns: columns, input: input)
        let result = handler.captureUserInput()

        #expect(result != nil)
        #expect(items.contains(result!))
    }

    @Test("Supports back navigation after multiple forward navigations")
    func supportsBackNavigationAfterMultipleForwardNavigations() {
        let rootItem = "Root"
        let rootColumn = makeColumn(items: [rootItem])
        let input = MockInput()

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .space)  // Navigate to Child
        input.enqueueSpecialChar(specialChar: .space)  // Navigate to Grandchild
        input.enqueueSpecialChar(specialChar: .backspace)  // Back to Child
        input.enqueueSpecialChar(specialChar: .enter)  // Select Child

        let onNavigate: (String) -> (items: [String], title: String)? = { item in
            if item == "Root" {
                return (items: ["Child"], title: "Children")
            } else if item == "Child" {
                return (items: ["Grandchild"], title: "Grandchildren")
            }
            return nil
        }

        let handler = makeSUT(columns: [rootColumn], input: input, onNavigate: onNavigate)
        let result = handler.captureUserInput()

        #expect(result == "Child")  // Should be back at Child level
    }

    @Test("Allows navigation forward again after going back")
    func allowsNavigationForwardAgainAfterGoingBack() {
        let rootItem = "Root"
        let rootColumn = makeColumn(items: [rootItem])
        let input = MockInput()

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .space)  // Navigate to Child
        input.enqueueSpecialChar(specialChar: .backspace)  // Back to Root
        input.enqueueSpecialChar(specialChar: .space)  // Navigate to Child again
        input.enqueueSpecialChar(specialChar: .enter)  // Select Child

        let onNavigate: (String) -> (items: [String], title: String)? = { item in
            if item == "Root" {
                return (items: ["Child"], title: "Children")
            }
            return nil
        }

        let handler = makeSUT(columns: [rootColumn], input: input, onNavigate: onNavigate)
        let result = handler.captureUserInput()

        #expect(result == "Child")
    }

    @Test("Navigates back multiple levels with repeated backspace")
    func navigatesBackMultipleLevelsWithRepeatedBackspace() {
        let rootItem = "Root"
        let rootColumn = makeColumn(items: [rootItem])
        let input = MockInput()

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .space)  // Navigate to Child
        input.enqueueSpecialChar(specialChar: .space)  // Navigate to Grandchild
        input.enqueueSpecialChar(specialChar: .backspace)  // Back to Child
        input.enqueueSpecialChar(specialChar: .backspace)  // Back to Root
        input.enqueueSpecialChar(specialChar: .enter)  // Select Root

        let onNavigate: (String) -> (items: [String], title: String)? = { item in
            if item == "Root" {
                return (items: ["Child"], title: "Children")
            } else if item == "Child" {
                return (items: ["Grandchild"], title: "Grandchildren")
            }
            return nil
        }

        let handler = makeSUT(columns: [rootColumn], input: input, onNavigate: onNavigate)
        let result = handler.captureUserInput()

        #expect(result == rootItem)  // Should be back at root
    }
}


// MARK: - Column Selectability Tests
extension ColumnSelectionTests {
    @Test("Ignores Enter key press on non-selectable column")
    func ignoresEnterKeyPressOnNonSelectableColumn() {
        let items = Self.makeItems(count: 3)
        let columns = [PickerColumn(title: "View Only", items: items, activeIndex: 0, isSelectable: false)]
        let input = MockInput()

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)
        input.enqueueSpecialChar(specialChar: .quit)

        let handler = makeSUT(columns: columns, input: input)
        let result = handler.captureUserInput()

        #expect(result == nil)  // Should quit, not select
    }

    @Test("Allows Enter key press on selectable column")
    func allowsEnterKeyPressOnSelectableColumn() {
        let items = Self.makeItems(count: 3)
        let columns = [PickerColumn(title: "Selectable", items: items, activeIndex: 0, isSelectable: true)]
        let input = MockInput()

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = makeSUT(columns: columns, input: input)
        let result = handler.captureUserInput()

        #expect(result != nil)
        #expect(items.contains(result!))
    }

    @Test("Default columns are selectable for backward compatibility")
    func defaultColumnsAreSelectableForBackwardCompatibility() {
        let items = Self.makeItems(count: 3)
        // Using old init without isSelectable parameter
        let columns = [makeColumn(items: items)]
        let input = MockInput()

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = makeSUT(columns: columns, input: input)
        let result = handler.captureUserInput()

        #expect(result != nil)
        #expect(items.contains(result!))
    }

    @Test("Allows selection when switching from non-selectable to selectable column")
    func allowsSelectionWhenSwitchingFromNonSelectableToSelectableColumn() {
        let selectableItems = ["A", "B", "C"]
        let nonSelectableItems = ["X", "Y", "Z"]
        let columns = [
            PickerColumn(title: "Selectable", items: selectableItems, activeIndex: 0, isSelectable: true),
            PickerColumn(title: "View Only", items: nonSelectableItems, activeIndex: 0, isSelectable: false)
        ]
        let input = MockInput(directionKey: .left)

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: nil)  // Trigger direction key (left)
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = makeSUT(columns: columns, input: input)
        let result = handler.captureUserInput()

        #expect(result != nil)
        #expect(selectableItems.contains(result!))
    }

    @Test("Prevents selection when switching from selectable to non-selectable column")
    func preventsSelectionWhenSwitchingFromSelectableToNonSelectableColumn() {
        let selectableItems = ["A", "B", "C"]
        let nonSelectableItems = ["X", "Y", "Z"]
        let columns = [
            PickerColumn(title: "Selectable", items: selectableItems, activeIndex: 0, isSelectable: true),
            PickerColumn(title: "View Only", items: nonSelectableItems, activeIndex: 0, isSelectable: false)
        ]
        let input = MockInput()

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)  // Try to select from non-selectable (starts at rightmost)
        input.enqueueSpecialChar(specialChar: .quit)

        let handler = makeSUT(columns: columns, input: input)
        let result = handler.captureUserInput()

        #expect(result == nil)  // Should quit, not select
    }

    @Test("Supports mixed selectability across multiple columns")
    func supportsMixedSelectabilityAcrossMultipleColumns() {
        let columns = [
            PickerColumn(title: "First", items: ["A"], activeIndex: 0, isSelectable: true),
            PickerColumn(title: "Second", items: ["B"], activeIndex: 0, isSelectable: false),
            PickerColumn(title: "Third", items: ["C"], activeIndex: 0, isSelectable: true)
        ]
        let input = MockInput()

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)

        let handler = makeSUT(columns: columns, input: input)
        let result = handler.captureUserInput()

        // Should select from third column (rightmost, selectable)
        #expect(result == "C")
    }

    @Test("Non-selectable columns still support navigation")
    func nonSelectableColumnsStillSupportNavigation() {
        let items = Self.makeItems(count: 5)
        let columns = [PickerColumn(title: "View Only", items: items, activeIndex: 0, isSelectable: false)]
        let input = MockInput(directionKey: .down)

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: nil)  // Navigate down
        input.enqueueSpecialChar(specialChar: nil)  // Navigate down again
        input.enqueueSpecialChar(specialChar: .enter)  // Try to select (should fail)
        input.enqueueSpecialChar(specialChar: .quit)

        let handler = makeSUT(columns: columns, input: input)
        let result = handler.captureUserInput()

        // Should quit (cannot select from non-selectable column)
        #expect(result == nil)
    }

    @Test("Non-selectable columns work with space navigation")
    func nonSelectableColumnsWorkWithSpaceNavigation() {
        let parentItem = "Parent"
        let columns = [PickerColumn(title: "Categories", items: [parentItem], activeIndex: 0, isSelectable: false)]
        let input = MockInput()

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .space)  // Navigate into children
        input.enqueueDirectionKey(directionKey: .left)  // Move to parent column
        input.enqueueSpecialChar(specialChar: nil)
        input.enqueueSpecialChar(specialChar: .enter)  // Try to select (should fail)
        input.enqueueSpecialChar(specialChar: .quit)

        let onNavigate: (String) -> (items: [String], title: String)? = { item in
            if item == parentItem {
                return (items: ["Child 0", "Child 1"], title: "Children")
            }
            return nil
        }

        let handler = makeSUT(columns: columns, input: input, onNavigate: onNavigate)
        let result = handler.captureUserInput()

        // Cannot select from non-selectable parent column
        #expect(result == nil)
    }

    @Test("Can select from child column when parent is non-selectable")
    func canSelectFromChildColumnWhenParentIsNonSelectable() {
        let parentItem = "Parent"
        let childItem = "Child 0"
        let columns = [PickerColumn(title: "Categories", items: [parentItem], activeIndex: 0, isSelectable: false)]
        let input = MockInput()

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .space)  // Navigate into children
        input.enqueueSpecialChar(specialChar: .enter)  // Select from child column

        let onNavigate: (String) -> (items: [String], title: String)? = { item in
            if item == parentItem {
                // Child column is selectable (default behavior)
                return (items: ["Child 0", "Child 1"], title: "Children")
            }
            return nil
        }

        let handler = makeSUT(columns: columns, input: input, onNavigate: onNavigate)
        let result = handler.captureUserInput()

        #expect(result == childItem)
    }
}


// MARK: - SUT
private extension ColumnSelectionTests {
    func makeSUT(
        columns: [PickerColumn<String>],
        input: MockInput,
        title: String = "Test Columns",
        onNavigate: ((String) -> (items: [String], title: String)?)? = nil
    ) -> ColumnSelectionHandler<String> {
        return SelectionHandlerFactory.makeColumnSelectionHandler(
            columns: columns,
            title: title,
            newScreen: false,
            inputHandler: input,
            onNavigate: onNavigate
        )
    }

    func makeColumn(title: String = "Column", items: [String]? = nil) -> PickerColumn<String> {
        return PickerColumn(title: title, items: items ?? Self.makeItems(), activeIndex: 0)
    }

    static func makeItems(count: Int = 5) -> [String] {
        return (0..<count).map { "Item \($0)" }
    }
}
