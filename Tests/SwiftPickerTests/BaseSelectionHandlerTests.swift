//
//  BaseSelectionHandlerTests.swift
//
//
//  Created by Nikolai Nobadi on 5/17/24.
//

import Testing
@testable import SwiftPicker

struct BaseSelectionHandlerTests {
    @Test("Selection handler starts with clean terminal state")
    func init_startingValues() {
        let (_, input) = makeSUT(state: makeState())
        
        #expect(input.writtenText.isEmpty)
        #expect(!input.didEnableNormalInput)
        #expect(!input.didExitAlternateScreen)
    }
    
    @Test("Ending selection restores normal terminal input mode")
    func endSelection() {
        let (sut, input) = makeSUT(state: makeState())
        
        sut.endSelection()
        
        #expect(input.didEnableNormalInput)
        #expect(input.didExitAlternateScreen)
    }
    
    @Test("User sees all available options when selection starts")
    func scrollAndRenderOptions_startingValues() {
        let state = makeState()
        let (sut, input) = makeSUT(state: state)
        
        assertWrittenText(sut: sut, input: input)
    }
    
    @Test("User can navigate through all options with arrow keys")
    func handleArrowKeys_activeLineUpdates() {
        let state = makeState()
        let (sut, input) = makeSUT(state: state, directionKey: .down)
        
        var count = 0
        for _ in 0..<20 {
            #expect(state.activeLine == count + PickerPadding.top)
            sut.handleArrowKeys()
            count += 1
        }
        
        input.directionKey = .up
        for _ in 0..<20 {
            #expect(state.activeLine == count + PickerPadding.top)
            sut.handleArrowKeys()
            count -= 1
        }
    }
    
    @Test("User sees selection update after pressing arrow key")
    func handleArrowKeys() {
        let activeIndex = 1
        let state = makeState()
        let (sut, input) = makeSUT(state: state, directionKey: .down)
        
        sut.handleArrowKeys()
        
        assertWrittenText(sut: sut, input: input, activeIndex: activeIndex)
    }
}


// MARK: - SUT
private extension BaseSelectionHandlerTests {
    func makeSUT(state: SelectionState<String>, screenSize: (Int, Int) = (26, 100), directionKey: Direction? = nil) -> (sut: BaseSelectionHandler<String>, input: MockInput) {
        let input = MockInput(screenSize: screenSize, directionKey: directionKey)
        let sut = BaseSelectionHandler(state: state, inputHandler: input)
        
        return (sut, input)
    }
    
    func makeOptions(items: [String]) -> [Option<String>] {
        return items.enumerated().map { .init(item: $1, line: PickerPadding.top + $0) }
    }
    
    func makeState() -> SelectionState<String> {
        let options = makeOptions(items: makeItems())
        
        return .init(options: options, topLine: PickerPadding.top, title: "This is my title", isSingleSelection: true)
    }
    
    func makeItems() -> [String] {
        return (1...25).map({ "Item \($0)" })
    }
}


// MARK: - Helper Assertions
private extension BaseSelectionHandlerTests {
    func assertWrittenText(sut: BaseSelectionHandler<String>, input: MockInput, activeIndex: Int = 0, sourceLocation: SourceLocation = #_sourceLocation) {
        let state = sut.state
        let expectedActiveLine = PickerPadding.top + activeIndex
        let headerText = [state.topLineText, "\n", "\n", state.title, "\n"]
        var displayableText: [String] = []
        for i in 0..<20 {
            displayableText.append(i == activeIndex ? "" : "○")
            displayableText.append(state.options[i].title)
        }
        let footerText = ["\n", "", "\n", state.bottomLineText]
        let allText = headerText + displayableText + footerText
        
        sut.scrollAndRenderOptions()
    
        #expect(state.activeLine == expectedActiveLine, "wrong active line", sourceLocation: sourceLocation)
        
        allText.enumerated().forEach {
            if !$1.isEmpty {
                #expect(input.writtenText[$0].contains($1), "writtenText: \(input.writtenText[$0]) is not equal to \($1)", sourceLocation: sourceLocation)
            }
        }
    }
}
