//
//  SwiftPickerIntegrationTests.swift
//  
//
//  Created by Nikolai Nobadi on 5/17/24.
//

import Testing
@testable import SwiftPicker

struct SwiftPickerIntegrationTests {
    @Test("Mock input system initializes with proper defaults")
    func init_usingMockInput() {
        let input = MockInput(screenSize: (26, 100), directionKey: nil)
        
        #expect(input.directionKey == nil)
        #expect(input.writtenText.isEmpty)
        #expect(!input.didEnableNormalInput)
        #expect(!input.didExitAlternateScreen)
        #expect(input.specialKeyQueue.isEmpty)
        
        // test that the input state can be modified
        #expect(!input.pressKey)
        input.pressKey = true
        #expect(input.pressKey)
    }
}

// MARK: - Single Selection Behaviors  
extension SwiftPickerIntegrationTests {
    @Test("User can make a single selection by pressing Enter")
    func singleSelection() {
        let input = MockInput(screenSize: (26, 100), directionKey: nil)
        let info = makeInfo()
        let handler = SelectionHandlerFactory.makeSingleSelectionHandler(info: info, newScreen: true, inputHandler: input)
        
        input.pressKey = true
        input.enqueueSpecialChar(specialChar: SpecialChar.enter)
        
        let selectedItem = handler.captureUserInput()
        
        #expect(selectedItem != nil)
    }
}

// MARK: - Multi Selection Behaviors
extension SwiftPickerIntegrationTests {
    @Test("User can finish multi-selection without selecting any items")
    func multiSelection_noSelection() {
        let input = MockInput(screenSize: (26, 100), directionKey: nil)
        let info = makeInfo()
        let handler = SelectionHandlerFactory.makeMultiSelectionHandler(info: info, newScreen: true, inputHandler: input)
        
        input.pressKey = true
        input.enqueueSpecialChar(specialChar: SpecialChar.enter)
        
        let result = handler.captureUserInput()
        
        #expect(result.isEmpty)
    }
    
    @Test("User can select multiple items using spacebar then confirm with Enter")  
    func multiSelection_withMultipleSelections() {
        let info = makeInfo()
        let selectionCount = 6
        let input = MockInput(screenSize: (26, 100), directionKey: .down)
        let handler = SelectionHandlerFactory.makeMultiSelectionHandler(info: info, newScreen: true, inputHandler: input)
        
        input.pressKey = true
        
        // select items
        // after spaceBar is read, arrow key will be read
        // this emulates selecting then moving down
        for _ in 0..<selectionCount {
            input.enqueueSpecialChar(specialChar: SpecialChar.space)
        }
        
        input.enqueueSpecialChar(specialChar: SpecialChar.enter)
        
        let result = handler.captureUserInput()
        
        #expect(result.count == selectionCount)
    }
    
    @Test("User cannot navigate above the first option with up arrow")
    func multiSelection_movingUp_activeLineCannotRiseAboveTopLineLimit() {
        let info = makeInfo()
        let input = MockInput(screenSize: (26, 100), directionKey: .up)
        let handler = SelectionHandlerFactory.makeMultiSelectionHandler(info: info, newScreen: true, inputHandler: input)
        let state = handler.state
        let topLineLimit = PickerPadding.top
        
        input.pressKey = true
        
        #expect(state.activeLine == topLineLimit)
        for _ in 0..<5 {
            input.enqueueSpecialChar(specialChar: Optional<SpecialChar>.none)
        }
        input.enqueueSpecialChar(specialChar: SpecialChar.enter)
        
        let _ = handler.captureUserInput()
        
        #expect(state.activeLine == topLineLimit)
    }
    
    @Test("User can navigate down through all available options")
    func multiSelection_movingDown_activeLineUpdates() {
        let itemCount = 25
        let items = makeItems(itemCount: itemCount)
        let info = makeInfo(items: items)
        let directionCount = itemCount
        let input = MockInput(screenSize: (26, 100), directionKey: .down)
        let handler = SelectionHandlerFactory.makeMultiSelectionHandler(info: info, newScreen: true, inputHandler: input)
        let state = handler.state
        
        /// # of items plus the amount of top padding = furthest down a row can be active
        let bottomLineLimit = itemCount + PickerPadding.top
        
        input.pressKey = true
        
        for _ in 0..<directionCount {
            input.enqueueSpecialChar(specialChar: Optional<SpecialChar>.none)
        }
        input.enqueueSpecialChar(specialChar: SpecialChar.enter)
        
        let _ = handler.captureUserInput()
        
        #expect(state.activeLine == bottomLineLimit)
    }
    
    @Test("User cannot navigate below the last option with down arrow")
    func multiSelection_movingDown_cannotMoveArrowBeyondLastItem() {
        let itemCount = 25
        let items = makeItems(itemCount: itemCount)
        let info = makeInfo(items: items)
        let directionCount = 30
        let input = MockInput(screenSize: (26, 100), directionKey: .down)
        let handler = SelectionHandlerFactory.makeMultiSelectionHandler(info: info, newScreen: true, inputHandler: input)
        let state = handler.state
        
        /// # of items plus the amount of top padding = furthest down a row can be active
        let bottomLineLimit = itemCount + PickerPadding.top
        
        input.pressKey = true
        
        for _ in 0..<directionCount {
            input.enqueueSpecialChar(specialChar: Optional<SpecialChar>.none)
        }
        input.enqueueSpecialChar(specialChar: SpecialChar.enter)
        
        let _ = handler.captureUserInput()
        
        #expect(state.activeLine == bottomLineLimit)
    }
}

// MARK: - Test Helpers
private extension SwiftPickerIntegrationTests {
    func makeInfo(title: String = "Title", items: [String]? = nil) -> PickerInfo<String> {
        return .init(title: title, items: items ?? makeItems())
    }
    
    func makeItems(itemCount: Int = 25) -> [String] {
        return (1...itemCount).map({ "Item \($0)" })
    }
}