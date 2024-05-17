//
//  BaseSelectionHandlerTests.swift
//
//
//  Created by Nikolai Nobadi on 5/17/24.
//

import XCTest
@testable import SwiftPicker

final class BaseSelectionHandlerTests: XCTestCase {
    func test_init_startingValues() {
        let (_, input) = makeSUT(state: makeState())
        
        XCTAssertTrue(input.writtenText.isEmpty)
        XCTAssertFalse(input.didEnableNormalInput)
        XCTAssertFalse(input.didExitAlternateScreen)
    }
    
    func test_endSelection() {
        let (sut, input) = makeSUT(state: makeState())
        
        sut.endSelection()
        
        XCTAssertTrue(input.didEnableNormalInput)
        XCTAssertTrue(input.didExitAlternateScreen)
    }
    
    func test_scrollAndRenderOptions_startingValues() {
        let state = makeState()
        let (sut, input) = makeSUT(state: state)
        let headerText = [state.topLineText, "\n", "\n", state.title, "\n"]
        var displayableText: [String] = []
        for i in 0..<20 {
            displayableText.append("○")
            displayableText.append(state.options[i].title)
        }
        let footerText = ["\n", "", "\n", state.bottomLineText]
        let allText = headerText + displayableText + footerText
        
        sut.scrollAndRenderOptions()
    
        XCTAssertEqual(state.activeLine, PickerPadding.top)
        
        allText.enumerated().forEach {
            if !$1.isEmpty {
                XCTAssertTrue(input.writtenText[$0].contains($1), "writtenText: \(input.writtenText[$0]) is not equal to \($1)")
            }
        }
    }
    
    func test_handleArrowKeys_activeLineUpdates() {
        let state = makeState()
        let (sut, input) = makeSUT(state: state, directionKey: .down)
        
        var count = 0
        for _ in 0..<20 {
            
            XCTAssertEqual(state.activeLine, count + PickerPadding.top)
            sut.handleArrowKeys()
            count += 1
        }
        
        input.directionKey = .up
        for _ in 0..<20 {
            XCTAssertEqual(state.activeLine, count + PickerPadding.top)
            sut.handleArrowKeys()
            count -= 1
        }
    }
    
    func test_handleArrowKeys() {
        let state = makeState()
        let (sut, input) = makeSUT(state: state, directionKey: .down)
        
        sut.handleArrowKeys()
        
        let headerText = [state.topLineText, "\n", "\n", state.title, "\n"]
        var displayableText: [String] = []
        for i in 0..<20 {
            displayableText.append("○")
            displayableText.append(state.options[i].title)
        }
        let footerText = ["\n", "", "\n", state.bottomLineText]
        let allText = headerText + displayableText + footerText
        
        sut.scrollAndRenderOptions()
    
        XCTAssertEqual(state.activeLine, PickerPadding.top + 1)
        
        allText.enumerated().forEach {
            if !$1.isEmpty {
                XCTAssertTrue(input.writtenText[$0].contains($1), "writtenText: \(input.writtenText[$0]) is not equal to \($1)")
            }
        }
    }
}


// MARK: - SUT
extension BaseSelectionHandlerTests {
    func makeSUT(state: SelectionState<String>, screenSize: (Int, Int) = (26, 100), directionKey: Direction? = nil) -> (sut: BaseSelectionHandler<String>, input: MockInput) {
        let input = MockInput(screenSize: screenSize, directionKey: directionKey)
        let sut = BaseSelectionHandler(state: state, inputHandler: input)
        
        return (sut, input)
    }
    
    func makeState() -> SelectionState<String> {
        let options = makeOptions(items: makeItems())
        return .init(options: options, topLine: PickerPadding.top, title: "This is my title", isSingleSelection: true)
    }
    
    func makeItems() -> [String] {
        return (1...25).map({ "Item \($0)" })
    }
    
    func makeOptions(items: [String]) -> [Option<String>] {
        return items.enumerated().map { .init(item: $1, line: PickerPadding.top + $0) }
    }
}


// MARK: - Helper Classes
extension BaseSelectionHandlerTests {
    class MockInput: PickerInput {
        var screenSize: (Int, Int)
        var directionKey: Direction?
        
        private(set) var writtenText: [String] = []
        private(set) var didEnableNormalInput = false
        private(set) var didExitAlternateScreen = false
        
        init(screenSize: (Int, Int), directionKey: Direction?) {
            self.screenSize = screenSize
            self.directionKey = directionKey
        }
        
        func moveRight() { }
        func moveToHome() { }
        func clearBuffer() { }
        func clearScreen() { }
        
        func enableNormalInput() {
            didEnableNormalInput = true
        }
        
        func keyPressed() -> Bool {
            return false
        }
        
        func write(_ text: String) {
            writtenText.append(text)
        }
        
        func exitAlternativeScreen() {
            didExitAlternateScreen = true
        }
        
        func enterAlternativeScreen() { }
        func moveTo(_ row: Int, _ col: Int) { }
        
        func readDirectionKey() -> Direction? {
            return directionKey
        }
        
        func readSpecialChar() -> SpecialChar? {
            return nil
        }
        
        func readCursorPos() -> (row: Int, col: Int) {
            return (0, 0)
        }
        
        func readScreenSize() -> (rows: Int, cols: Int) {
            return screenSize
        }
    }
}
