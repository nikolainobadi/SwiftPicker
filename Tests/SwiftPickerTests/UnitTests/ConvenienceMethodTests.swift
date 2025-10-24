//
//  ConvenienceMethodTests.swift
//  
//
//  Created by Nikolai Nobadi on 8/10/25.
//

import Testing
@testable import SwiftPicker

struct ConvenienceMethodTests {
    @Test("Single item selection constructs consistent state")
    func singleSelectionBuildsConsistentState() {
      let input = MockInput(screenSize: (30, 100), directionKey: nil)
      input.pressKey = true
      input.enqueueSpecialChar(specialChar: .enter)

      let info = makePickerInfo(title: "Default Screen", items: ["A","B","C"])
      let h1 = SelectionHandlerFactory.makeSingleSelectionHandler(info: info, newScreen: true, inputHandler: input)
      let h2 = SelectionHandlerFactory.makeSingleSelectionHandler(info: info, newScreen: false, inputHandler: input)

      #expect(h1.state.title == h2.state.title)
      #expect(h1.state.options.count == h2.state.options.count)
    }
    
    @Test("Custom titles display correctly during selection")
    func singleSelectionWithCustomTitleFormatting() {
        let items = ["Item 1", "Item 2"]
        let input = MockInput(screenSize: (30, 100), directionKey: nil)

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)

        let customTitle = "🎯 Choose Your Target"
        let info = makePickerInfo(title: customTitle, items: items)
        let handler = SelectionHandlerFactory.makeSingleSelectionHandler(info: info, newScreen: false, inputHandler: input)

        #expect(handler.state.title == customTitle)

        let result = handler.captureUserInput()
        #expect(result == items[0])
    }
}

// MARK: - Multi Selection Convenience Methods  
extension ConvenienceMethodTests {
    @Test("Multiple items selected and confirmed returns correct results")
    func multiSelectionWithDefaultNewScreenParameterWorksCorrectly() {
        let items = ["Choice 1", "Choice 2", "Choice 3"]
        let input = MockInput(screenSize: (30, 100), directionKey: .down)

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .space) // Select first
        input.enqueueSpecialChar(specialChar: .space) // Select second
        input.enqueueSpecialChar(specialChar: .enter)  // Finish

        let info = makePickerInfo(title: "Multi Default", items: items)
        let handler = SelectionHandlerFactory.makeMultiSelectionHandler(info: info, newScreen: true, inputHandler: input)

        let result = handler.captureUserInput()

        #expect(result.count == 2)
        #expect(result.contains(items[0]))
        #expect(result.contains(items[1]))
    }
    
    @Test("Confirming without selections returns empty result")
    func multiSelectionAllowsNoSelections() {
        let items = ["A", "B", "C"]
        let input = MockInput(screenSize: (30, 100), directionKey: nil)
        
        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter) // Finish without selecting
        
        let info = makePickerInfo(title: "No Selection", items: items)
        let handler = SelectionHandlerFactory.makeMultiSelectionHandler(info: info, newScreen: false, inputHandler: input)
        
        let result = handler.captureUserInput()
        
        #expect(result.isEmpty)
    }
}

// MARK: - PickerInfo Convenience Tests
extension ConvenienceMethodTests {
    @Test("Selection configuration preserves title and items")
    func pickerInfoInitializesWithTitleAndItemsCorrectly() {
        let title = "Test Selection"
        let items = ["One", "Two", "Three"]
        
        let info = makePickerInfo(title: title, items: items)
        
        #expect(info.title == title)
        #expect(info.items == items)
        #expect(info.items.count == 3)
    }
    
    @Test("Custom item types display with correct formatting")
    func pickerInfoWorksWithDifferentDisplayablePickerItemTypes() {
        struct MenuItem: DisplayablePickerItem {
            let name: String
            let category: String

            var displayName: String {
                return "\(category): \(name)"
            }
        }

        let items = [
            MenuItem(name: "Burger", category: "Main"),
            MenuItem(name: "Fries", category: "Side"),
            MenuItem(name: "Soda", category: "Drink")
        ]

        let info = PickerInfo(title: "Restaurant Menu", items: items)

        #expect(info.title == "Restaurant Menu")
        #expect(info.items.count == 3)
        #expect(info.items[0].displayName == items[0].displayName)
        #expect(info.items[1].displayName == items[1].displayName)
        #expect(info.items[2].displayName == items[2].displayName)
    }
    
    @Test("Empty item lists maintain valid configuration")
    func pickerInfoHandlesEmptyItemsArray() {
        let items: [String] = []
        let info = makePickerInfo(title: "Empty List", items: items)
        
        #expect(info.title == "Empty List")
        #expect(info.items.isEmpty)
    }
}

// MARK: - Method Chaining and Fluent Interface Tests
extension ConvenienceMethodTests {
    @Test("Selection results support functional transformations")
    func selectionMethodsCanBeUsedInFunctionalStyle() {
        let items = ["Red", "Green", "Blue"]
        let input = MockInput(screenSize: (30, 100), directionKey: nil)

        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)

        // Test that methods return expected types for chaining
        let info = makePickerInfo(title: "Colors", items: items)
        let handler = SelectionHandlerFactory.makeSingleSelectionHandler(info: info, newScreen: false, inputHandler: input)

        let result = handler.captureUserInput()
        let processedResult = result?.uppercased()

        #expect(processedResult == items[0].uppercased())
    }
    
    @Test("Selection results chain with multiple operations")
    func multipleOperationsCanBePerformedOnSelectionResults() {
        let numbers = ["1", "2", "3", "4", "5"]
        let input = MockInput(screenSize: (30, 100), directionKey: .down)
        
        input.pressKey = true
        // Select multiple items
        input.enqueueSpecialChar(specialChar: .space) // Select "1"
        input.enqueueSpecialChar(specialChar: .space) // Select "2"
        input.enqueueSpecialChar(specialChar: .space) // Select "3"
        input.enqueueSpecialChar(specialChar: .enter)
        
        let info = makePickerInfo(title: "Numbers", items: numbers)
        let handler = SelectionHandlerFactory.makeMultiSelectionHandler(info: info, newScreen: false, inputHandler: input)
        
        let result = handler.captureUserInput()
        
        // Test functional operations on results
        let integers = result.compactMap { Int($0) }
        let sum = integers.reduce(0, +)
        let sortedResult = result.sorted()
        
        #expect(integers.count == result.count)
        #expect(sum == 6) // 1 + 2 + 3
        #expect(sortedResult == ["1", "2", "3"])
    }
}

// MARK: - Screen Configuration Tests
extension ConvenienceMethodTests {
    @Test("Screen configuration modes produce consistent state")
    func newScreenParameterAffectsScreenBehavior() {
        let items = ["Test Item"]
        let input = MockInput(screenSize: (30, 100), directionKey: nil)
        
        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)
        
        let info = makePickerInfo(title: "Screen Test", items: items)
        
        // Test with newScreen = true
        let handlerNewScreen = SelectionHandlerFactory.makeSingleSelectionHandler(info: info, newScreen: true, inputHandler: input)
        
        // Test with newScreen = false  
        let handlerSameScreen = SelectionHandlerFactory.makeSingleSelectionHandler(info: info, newScreen: false, inputHandler: input)
        
        // Both should work, but may have different screen setup
        #expect(handlerNewScreen.state.title == handlerSameScreen.state.title)
        #expect(handlerNewScreen.state.options.count == handlerSameScreen.state.options.count)
    }
    
    @Test("Selection behavior remains consistent across screen modes")
    func screenConfigurationDoesNotAffectSelectionLogic() {
        let items = ["Alpha", "Beta", "Gamma"]
        let input1 = MockInput(screenSize: (30, 100), directionKey: .down)
        let input2 = MockInput(screenSize: (30, 100), directionKey: .down)

        input1.pressKey = true
        input1.enqueueSpecialChar(specialChar: nil) // Down
        input1.enqueueSpecialChar(specialChar: .enter) // Select second item

        input2.pressKey = true
        input2.enqueueSpecialChar(specialChar: nil) // Down
        input2.enqueueSpecialChar(specialChar: .enter) // Select second item

        let info = makePickerInfo(title: "Screen Logic Test", items: items)
        let handlerNew = SelectionHandlerFactory.makeSingleSelectionHandler(info: info, newScreen: true, inputHandler: input1)
        let handlerSame = SelectionHandlerFactory.makeSingleSelectionHandler(info: info, newScreen: false, inputHandler: input2)

        let resultNew = handlerNew.captureUserInput()
        let resultSame = handlerSame.captureUserInput()

        #expect(resultNew == resultSame)
        #expect(resultNew == items[1])
    }
}

// MARK: - SUT
private extension ConvenienceMethodTests {
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
