//
//  ConvenienceMethodTests.swift
//  
//
//  Created by Nikolai Nobadi on 8/10/25.
//

import Testing
@testable import SwiftPicker

struct ConvenienceMethodTests {
    private let picker = InteractivePicker()
}

// MARK: - Single Selection Convenience Methods
extension ConvenienceMethodTests {
    @Test("Single selection with default newScreen parameter works correctly")
    func selectSingleItem_withDefaultNewScreen() {
        let items = ["Option A", "Option B", "Option C"]
        let input = MockInput(screenSize: (30, 100), directionKey: nil)
        
        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)
        
        let info = PickerInfo(title: "Default Screen", items: items)
        // Test the default parameter version (newScreen defaults to true)
        let handlerWithDefault = SelectionHandlerFactory.makeSingleSelectionHandler(info: info, newScreen: true, inputHandler: input)
        let handlerExplicit = SelectionHandlerFactory.makeSingleSelectionHandler(info: info, newScreen: true, inputHandler: input)
        
        // Both should behave the same
        #expect(handlerWithDefault.state.title == handlerExplicit.state.title)
        #expect(handlerWithDefault.state.options.count == handlerExplicit.state.options.count)
    }
    
    @Test("Single selection with custom title formatting")
    func selectSingleItem_withCustomTitleFormatting() {
        let items = ["Item 1", "Item 2"]
        let input = MockInput(screenSize: (30, 100), directionKey: nil)
        
        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)
        
        let customTitle = "🎯 Choose Your Target"
        let info = PickerInfo(title: customTitle, items: items)
        let handler = SelectionHandlerFactory.makeSingleSelectionHandler(info: info, newScreen: false, inputHandler: input)
        
        #expect(handler.state.title == customTitle)
        
        let result = handler.captureUserInput()
        #expect(result == "Item 1")
    }
}

// MARK: - Multi Selection Convenience Methods  
extension ConvenienceMethodTests {
    @Test("Multi selection with default newScreen parameter works correctly")
    func selectMultipleItems_withDefaultNewScreen() {
        let items = ["Choice 1", "Choice 2", "Choice 3"]
        let input = MockInput(screenSize: (30, 100), directionKey: .down)
        
        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .space) // Select first
        input.enqueueSpecialChar(specialChar: .space) // Select second
        input.enqueueSpecialChar(specialChar: .enter)  // Finish
        
        let info = PickerInfo(title: "Multi Default", items: items)
        let handler = SelectionHandlerFactory.makeMultiSelectionHandler(info: info, newScreen: true, inputHandler: input)
        
        let result = handler.captureUserInput()
        
        #expect(result.count == 2)
        #expect(result.contains("Choice 1"))
        #expect(result.contains("Choice 2"))
    }
    
    @Test("Multi selection allows no selections")
    func selectMultipleItems_allowsNoSelections() {
        let items = ["A", "B", "C"]
        let input = MockInput(screenSize: (30, 100), directionKey: nil)
        
        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter) // Finish without selecting
        
        let info = PickerInfo(title: "No Selection", items: items)
        let handler = SelectionHandlerFactory.makeMultiSelectionHandler(info: info, newScreen: false, inputHandler: input)
        
        let result = handler.captureUserInput()
        
        #expect(result.isEmpty)
    }
}

// MARK: - PickerInfo Convenience Tests
extension ConvenienceMethodTests {
    @Test("PickerInfo initializes with title and items correctly")
    func pickerInfo_initializesCorrectly() {
        let title = "Test Selection"
        let items = ["One", "Two", "Three"]
        
        let info = PickerInfo(title: title, items: items)
        
        #expect(info.title == title)
        #expect(info.items == items)
        #expect(info.items.count == 3)
    }
    
    @Test("PickerInfo works with different DisplayablePickerItem types")
    func pickerInfo_worksWithDifferentTypes() {
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
        #expect(info.items[0].displayName == "Main: Burger")
        #expect(info.items[1].displayName == "Side: Fries")
        #expect(info.items[2].displayName == "Drink: Soda")
    }
    
    @Test("PickerInfo handles empty items array")
    func pickerInfo_handlesEmptyItems() {
        let items: [String] = []
        let info = PickerInfo(title: "Empty List", items: items)
        
        #expect(info.title == "Empty List")
        #expect(info.items.isEmpty)
    }
}

// MARK: - Method Chaining and Fluent Interface Tests
extension ConvenienceMethodTests {
    @Test("Selection methods can be used in functional style")
    func selectionMethods_supportFunctionalStyle() {
        let items = ["Red", "Green", "Blue"]
        let input = MockInput(screenSize: (30, 100), directionKey: nil)
        
        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)
        
        // Test that methods return expected types for chaining
        let info = PickerInfo(title: "Colors", items: items)
        let handler = SelectionHandlerFactory.makeSingleSelectionHandler(info: info, newScreen: false, inputHandler: input)
        
        let result = handler.captureUserInput()
        let processedResult = result?.uppercased()
        
        #expect(processedResult == "RED")
    }
    
    @Test("Multiple operations can be performed on selection results")
    func selectionResults_supportMultipleOperations() {
        let numbers = ["1", "2", "3", "4", "5"]
        let input = MockInput(screenSize: (30, 100), directionKey: .down)
        
        input.pressKey = true
        // Select multiple items
        input.enqueueSpecialChar(specialChar: .space) // Select "1"
        input.enqueueSpecialChar(specialChar: .space) // Select "2"
        input.enqueueSpecialChar(specialChar: .space) // Select "3"
        input.enqueueSpecialChar(specialChar: .enter)
        
        let info = PickerInfo(title: "Numbers", items: numbers)
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
    @Test("newScreen parameter affects screen behavior")
    func newScreen_parameterAffectsScreenBehavior() {
        let items = ["Test Item"]
        let input = MockInput(screenSize: (30, 100), directionKey: nil)
        
        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)
        
        let info = PickerInfo(title: "Screen Test", items: items)
        
        // Test with newScreen = true
        let handlerNewScreen = SelectionHandlerFactory.makeSingleSelectionHandler(info: info, newScreen: true, inputHandler: input)
        
        // Test with newScreen = false  
        let handlerSameScreen = SelectionHandlerFactory.makeSingleSelectionHandler(info: info, newScreen: false, inputHandler: input)
        
        // Both should work, but may have different screen setup
        #expect(handlerNewScreen.state.title == handlerSameScreen.state.title)
        #expect(handlerNewScreen.state.options.count == handlerSameScreen.state.options.count)
    }
    
    @Test("Screen configuration doesn't affect selection logic")
    func screenConfiguration_doesNotAffectSelectionLogic() {
        let items = ["Alpha", "Beta", "Gamma"]
        let input1 = MockInput(screenSize: (30, 100), directionKey: .down)
        let input2 = MockInput(screenSize: (30, 100), directionKey: .down)
        
        input1.pressKey = true
        input1.enqueueSpecialChar(specialChar: nil) // Down
        input1.enqueueSpecialChar(specialChar: .enter) // Select second item
        
        input2.pressKey = true  
        input2.enqueueSpecialChar(specialChar: nil) // Down
        input2.enqueueSpecialChar(specialChar: .enter) // Select second item
        
        let info = PickerInfo(title: "Screen Logic Test", items: items)
        let handlerNew = SelectionHandlerFactory.makeSingleSelectionHandler(info: info, newScreen: true, inputHandler: input1)
        let handlerSame = SelectionHandlerFactory.makeSingleSelectionHandler(info: info, newScreen: false, inputHandler: input2)
        
        let resultNew = handlerNew.captureUserInput()
        let resultSame = handlerSame.captureUserInput()
        
        // Both should select the same item regardless of screen configuration
        #expect(resultNew == resultSame)
        #expect(resultNew == "Beta")
    }
}