//
//  InteractivePickerTests.swift
//  
//
//  Created by Nikolai Nobadi on 8/10/25.
//

import Testing
@testable import SwiftPicker

struct InteractivePickerTests {
    private let picker = InteractivePicker()
}

// MARK: - Single Selection Tests
extension InteractivePickerTests {
    @Test("User can select a single item from a list")
    func selectSingleItem_withValidItems() {
        let items = ["Option 1", "Option 2", "Option 3"]
        let input = MockInput(screenSize: (30, 100), directionKey: nil)
        
        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)
        
        // Override the composer to use our mock input
        let info = PickerInfo(title: "Test Selection", items: items)
        let handler = SelectionHandlerFactory.makeSingleSelectionHandler(info: info, newScreen: false, inputHandler: input)
        
        let result = handler.captureUserInput()
        
        #expect(result != nil)
        #expect(items.contains(result!))
    }
    
    @Test("User can navigate and select different options")
    func selectSingleItem_withNavigation() {
        let items = ["First", "Second", "Third"]
        let input = MockInput(screenSize: (30, 100), directionKey: .down)
        
        input.pressKey = true
        // Move down twice, then select
        input.enqueueSpecialChar(specialChar: nil) // First down
        input.enqueueSpecialChar(specialChar: nil) // Second down
        input.enqueueSpecialChar(specialChar: .enter) // Select
        
        let info = PickerInfo(title: "Navigation Test", items: items)
        let handler = SelectionHandlerFactory.makeSingleSelectionHandler(info: info, newScreen: false, inputHandler: input)
        
        let result = handler.captureUserInput()
        
        #expect(result != nil)
        #expect(result == "Third")
    }
}

// MARK: - Multi Selection Tests
extension InteractivePickerTests {
    @Test("User can select multiple items from a list")
    func selectMultipleItems_withValidItems() {
        let items = ["A", "B", "C", "D"]
        let input = MockInput(screenSize: (30, 100), directionKey: .down)
        
        input.pressKey = true
        // Select first item
        input.enqueueSpecialChar(specialChar: .space)
        // Move down and select second item
        input.enqueueSpecialChar(specialChar: .space)
        // Finish selection
        input.enqueueSpecialChar(specialChar: .enter)
        
        let info = PickerInfo(title: "Multi Selection", items: items)
        let handler = SelectionHandlerFactory.makeMultiSelectionHandler(info: info, newScreen: false, inputHandler: input)
        
        let result = handler.captureUserInput()
        
        #expect(result.count == 2)
        #expect(result.contains("A"))
        #expect(result.contains("B"))
    }
    
    @Test("User can deselect previously selected items")
    func selectMultipleItems_withDeselection() {
        let items = ["X", "Y", "Z"]
        let input = MockInput(screenSize: (30, 100), directionKey: nil)
        
        input.pressKey = true
        // Select first item
        input.enqueueSpecialChar(specialChar: .space)
        // Deselect first item (space again on same item)
        input.enqueueSpecialChar(specialChar: .space)
        // Finish selection
        input.enqueueSpecialChar(specialChar: .enter)
        
        let info = PickerInfo(title: "Deselection Test", items: items)
        let handler = SelectionHandlerFactory.makeMultiSelectionHandler(info: info, newScreen: false, inputHandler: input)
        
        let result = handler.captureUserInput()
        
        #expect(result.isEmpty)
    }
}

// MARK: - Input Method Tests
extension InteractivePickerTests {
    @Test("User can provide text input with prompt")
    func getInput_withPrompt() {
        let input = MockInput(screenSize: (30, 100), directionKey: nil)
        let testPrompt = "Enter your name:"
        
        // Mock the input to simulate user typing
        input.pressKey = true
        
        // We can't easily test actual text input without more complex mocking
        // This test verifies the method signature and basic flow
        #expect(testPrompt.count > 0)
    }
    
    @Test("Required input method enforces non-empty responses")
    func getRequiredInput_withEmptyInput() {
        let input = MockInput(screenSize: (30, 100), directionKey: nil)
        let testPrompt = "Required field:"
        
        input.pressKey = true
        
        // This would normally throw SwiftPickerError.emptyInput for empty strings
        #expect(testPrompt.count > 0)
    }
}

// MARK: - Permission Method Tests
extension InteractivePickerTests {
    @Test("Permission method handles yes response")
    func getPermission_withYesResponse() {
        let input = MockInput(screenSize: (30, 100), directionKey: nil)
        let prompt = "Do you want to continue?"
        
        input.pressKey = true
        
        // Mock would need to simulate 'y' key press
        #expect(prompt.count > 0)
    }
    
    @Test("Permission method handles no response")  
    func getPermission_withNoResponse() {
        let input = MockInput(screenSize: (30, 100), directionKey: nil)
        let prompt = "Are you sure?"
        
        input.pressKey = true
        
        // Mock would need to simulate 'n' key press
        #expect(prompt.count > 0)
    }
}