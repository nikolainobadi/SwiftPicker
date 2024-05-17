//
//  IntegrationTests.swift
//  
//
//  Created by Nikolai Nobadi on 5/17/24.
//

import XCTest
@testable import SwiftPicker

final class IntegrationTests: XCTestCase {
    func test_init_usingMockInput() {
        let (sut, input) = makeSUT()
        
        guard let mockInput = sut.inputHandler as? MockInput else {
            return XCTFail()
        }
        
        XCTAssertNil(mockInput.directionKey)
        XCTAssertTrue(input.writtenText.isEmpty)
        XCTAssertFalse(input.didEnableNormalInput)
        XCTAssertFalse(input.didExitAlternateScreen)
        XCTAssertTrue(mockInput.specialKeyQueue.isEmpty)
        
        // ensure that mockInput is the same instance as input
        XCTAssertFalse(mockInput.pressKey)
        input.pressKey = true
        XCTAssertTrue(mockInput.pressKey)
    }
}


// MARK: - SingleSelection
extension IntegrationTests {
    func test_singleSelection() {
        let (sut, input) = makeSUT()
        let info = makeInfo()
        let handler = sut.makeSingleSelectionHandler(info: info, newScreen: true)
        
        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)
        
        let selectedItem = handler.captureUserInput()
        
        XCTAssertNotNil(selectedItem)
    }
}


// MARK: - MultiSelection
extension IntegrationTests {
    func test_multiSelection_noSelection() {
        let (sut, input) = makeSUT()
        let info = makeInfo()
        let handler = sut.makeMultiSelectionHandler(info: info, newScreen: true)
        
        input.pressKey = true
        input.enqueueSpecialChar(specialChar: .enter)
        
        let result = handler.captureUserInput()
        
        XCTAssertTrue(result.isEmpty)
    }
    
    func test_multiSelection_withMultipleSelections() {
        let info = makeInfo()
        let selectionCount = 6
        let (sut, input) = makeSUT()
        let handler = sut.makeMultiSelectionHandler(info: info, newScreen: true)
        
        input.pressKey = true
        input.directionKey = .down
        
        // select items
        // after spaceBar is read, arrow key will be read
        // this emulates selecting then moving down
        for _ in 0..<selectionCount {
            input.enqueueSpecialChar(specialChar: .space)
        }
        input.enqueueSpecialChar(specialChar: .enter)
        
        let result = handler.captureUserInput()
        
        XCTAssertEqual(result.count, selectionCount)
    }
    
    func test_multiSelection_movingUp_activeLineCannotRiseAboveTopLineLimit() {
        let info = makeInfo()
        let (sut, input) = makeSUT()
        let handler = sut.makeMultiSelectionHandler(info: info, newScreen: true)
        let state = handler.state
        let topLineLimit = PickerPadding.top
        
        input.pressKey = true
        input.directionKey = .up
        
        XCTAssertEqual(state.activeLine, topLineLimit)
        for _ in 0..<5 {
            input.enqueueSpecialChar(specialChar: nil)
        }
        input.enqueueSpecialChar(specialChar: .enter)
        
        let _ = handler.captureUserInput()
        
        XCTAssertEqual(state.activeLine, topLineLimit)
    }
    
    func test_multiSelection_movingDown_activeLineUpdates() {
        let itemCount = 25
        let items = makeItems(itemCount: itemCount)
        let info = makeInfo(items: items)
        let directionCount = itemCount
        let (sut, input) = makeSUT()
        let handler = sut.makeMultiSelectionHandler(info: info, newScreen: true)
        let state = handler.state
        
        /// # of items plus the amount of top padding = furthest down a row can be active
        let bottomLineLimit = itemCount + PickerPadding.top
        
        input.pressKey = true
        input.directionKey = .down
        
        for _ in 0..<directionCount {
            input.enqueueSpecialChar(specialChar: nil)
        }
        input.enqueueSpecialChar(specialChar: .enter)
        
        let _ = handler.captureUserInput()
        
        XCTAssertEqual(state.activeLine, bottomLineLimit)
    }
    
    func test_multiSelection_movingDown_cannotMoveArrowBeyondLastItem() {
        let itemCount = 25
        let items = makeItems(itemCount: itemCount)
        let info = makeInfo(items: items)
        let directionCount = 30
        let (sut, input) = makeSUT()
        let handler = sut.makeMultiSelectionHandler(info: info, newScreen: true)
        let state = handler.state
        
        /// # of items plus the amount of top padding = furthest down a row can be active
        let bottomLineLimit = itemCount + PickerPadding.top
        
        input.pressKey = true
        input.directionKey = .down
        
        for _ in 0..<directionCount {
            input.enqueueSpecialChar(specialChar: nil)
        }
        input.enqueueSpecialChar(specialChar: .enter)
        
        let _ = handler.captureUserInput()
        
        XCTAssertEqual(state.activeLine, bottomLineLimit)
    }
}


// MARK: - SUT
extension IntegrationTests {
    func makeSUT(screenSize: (Int, Int) = (26, 100), directionKey: Direction? = nil) -> (sut: PickerComposer.Type, input: MockInput) {
        let input = MockInput(screenSize: screenSize, directionKey: directionKey)
        let sut = PickerComposer.self
        
        sut.inputHandler = input
        
        return (sut, input)
    }
    
    func makeInfo(title: String = "Title", items: [String]? = nil) -> PickerInfo<String> {
        return .init(title: title, items: items ?? makeItems())
    }
    
    func makeItems(itemCount: Int = 25) -> [String] {
        return (1...itemCount).map({ "Item \($0)" })
    }
}
