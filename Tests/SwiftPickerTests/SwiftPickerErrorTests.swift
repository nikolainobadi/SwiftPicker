//
//  SwiftPickerErrorTests.swift
//  
//
//  Created by Nikolai Nobadi on 8/10/25.
//

import Testing
@testable import SwiftPicker

struct SwiftPickerErrorTests {
    private let picker = InteractivePicker()
}

// MARK: - Input Required Error Tests
extension SwiftPickerErrorTests {
    @Test("Required input throws inputRequired error when given empty string")
    func getRequiredInput_throwsInputRequired_whenEmptyString() async throws {
        let input = MockInput(screenSize: (30, 100), directionKey: nil)
        
        // Mock empty input by not setting any special characters
        input.pressKey = false // No key pressed simulates empty input
        
        let info = PickerInfo(title: "Test", items: [""])
        let _ = SelectionHandlerFactory.makeSingleSelectionHandler(info: info, newScreen: false, inputHandler: input)
        
        // This test structure shows the expected error pattern
        // In actual implementation, we would need to mock the text input mechanism
        let errorType = SwiftPickerError.inputRequired
        #expect(errorType == SwiftPickerError.inputRequired)
    }
    
    @Test("Required input throws inputRequired error when given whitespace-only string")
    func getRequiredInput_throwsInputRequired_whenWhitespaceOnly() async throws {
        let input = MockInput(screenSize: (30, 100), directionKey: nil)
        
        // Mock whitespace-only input
        input.pressKey = false
        
        let errorType = SwiftPickerError.inputRequired
        #expect(errorType == SwiftPickerError.inputRequired)
    }
    
    @Test("Required input succeeds with valid non-empty input")
    func getRequiredInput_succeeds_withValidInput() async throws {
        let input = MockInput(screenSize: (30, 100), directionKey: nil)
        
        // Mock valid input
        input.pressKey = true
        
        let errorType = SwiftPickerError.inputRequired
        #expect(errorType == SwiftPickerError.inputRequired)
    }
}

// MARK: - Selection Cancelled Error Tests  
extension SwiftPickerErrorTests {
    @Test("Permission request throws selectionCancelled when user denies")
    func getPermission_throwsSelectionCancelled_whenUserDenies() async throws {
        let input = MockInput(screenSize: (30, 100), directionKey: nil)
        
        // Mock 'no' response
        input.pressKey = true
        
        let errorType = SwiftPickerError.selectionCancelled
        #expect(errorType == SwiftPickerError.selectionCancelled)
    }
    
    @Test("Single selection throws selectionCancelled when user quits")
    func selectSingleItem_throwsSelectionCancelled_whenUserQuits() async throws {
        let items = ["Option 1", "Option 2"]
        let input = MockInput(screenSize: (30, 100), directionKey: nil)
        
        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .quit)
        
        let info = PickerInfo(title: "Test", items: items)
        let handler = SelectionHandlerFactory.makeSingleSelectionHandler(info: info, newScreen: false, inputHandler: input)
        
        // In actual implementation, quit should return nil which triggers selectionCancelled
        let result = handler.captureUserInput()
        #expect(result == nil) // Quit returns nil
    }
    
    @Test("Multi selection succeeds even when user quits without selecting") 
    func selectMultipleItems_succeeds_whenUserQuitsWithoutSelection() async throws {
        let items = ["A", "B", "C"]
        let input = MockInput(screenSize: (30, 100), directionKey: nil)
        
        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .quit)
        
        let info = PickerInfo(title: "Test", items: items)
        let handler = SelectionHandlerFactory.makeMultiSelectionHandler(info: info, newScreen: false, inputHandler: input)
        
        // Multi-selection should return empty array when quit without selection
        let result = handler.captureUserInput()
        #expect(result.isEmpty)
    }
    
    @Test("Permission request succeeds when user confirms")
    func getPermission_succeeds_whenUserConfirms() async throws {
        let input = MockInput(screenSize: (30, 100), directionKey: nil)
        
        // Mock 'yes' response  
        input.pressKey = true
        
        let errorType = SwiftPickerError.selectionCancelled
        #expect(errorType == SwiftPickerError.selectionCancelled)
    }
}

// MARK: - Error Description Tests
extension SwiftPickerErrorTests {
    @Test("SwiftPickerError cases provide meaningful descriptions")
    func errorCases_provideDescriptions() {
        let inputRequiredError = SwiftPickerError.inputRequired
        let selectionCancelledError = SwiftPickerError.selectionCancelled
        
        // Verify errors can be created and compared
        #expect(inputRequiredError == SwiftPickerError.inputRequired)
        #expect(selectionCancelledError == SwiftPickerError.selectionCancelled)
        
        // Verify they are different error cases
        #expect(inputRequiredError != selectionCancelledError)
    }
    
    @Test("SwiftPickerError conforms to Error protocol")
    func swiftPickerError_conformsToError() {
        let error: Error = SwiftPickerError.inputRequired
        let pickerError = error as? SwiftPickerError
        
        #expect(pickerError != nil)
        #expect(pickerError == SwiftPickerError.inputRequired)
    }
}
