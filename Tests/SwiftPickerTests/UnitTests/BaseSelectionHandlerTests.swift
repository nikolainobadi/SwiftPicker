//
//  BaseSelectionHandlerTests.swift
//
//
//  Created by Nikolai Nobadi on 5/17/24.
//

import Testing
@testable import SwiftPicker

struct BaseSelectionHandlerTests {
    @Test("Terminal state initializes clean with correct configuration")
    func selectionHandlerStartsWithCleanTerminalState() {
        let title = "This is my title"
        let itemCount = 25
        let topLine = PickerPadding.top
        let state = makeState()
        let (sut, input) = makeSUT(state: state)

        #expect(input.writtenText.isEmpty)
        #expect(!input.didEnableNormalInput)
        #expect(!input.didExitAlternateScreen)
        #expect(sut.state.title == title)
        #expect(sut.state.options.count == itemCount)
        #expect(sut.state.topLine == topLine)
        #expect(sut.state.activeLine == topLine)
        #expect(sut.state.isSingleSelection)
        #expect(sut.state.selectedOptions.isEmpty)
        #expect(sut.state.rangeOfLines.minimum == topLine)
        #expect(sut.state.rangeOfLines.maximum == topLine + itemCount - 1)
        #expect(sut.state.topLineText == "InteractivePicker (single-selection)")
        #expect(sut.state.bottomLineText == "Tap 'enter' to select. Type 'q' to quit.")
    }
    
    @Test("Terminal restores to normal input mode after selection ends")
    func endingSelectionRestoresNormalTerminalInputMode() {
        let (sut, input) = makeSUT(state: makeState())

        sut.endSelection()

        #expect(input.didEnableNormalInput)
        #expect(input.didExitAlternateScreen)
    }
    
    @Test("All available options display when selection starts")
    func userSeesAllAvailableOptionsWhenSelectionStarts() {
        let state = makeState()
        let (sut, input) = makeSUT(state: state)

        assertWrittenText(sut: sut, input: input)
    }
    
    @Test("Arrow key navigation cycles through all available options")
    func userCanNavigateThroughAllOptionsWithArrowKeys() {
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
    
    @Test("Display updates to reflect new selection after arrow key press")
    func userSeesSelectionUpdateAfterPressingArrowKey() {
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
    var selectedIndicator: String { "●" }
    var unselectedIndicator: String { "○" }

    func assertWrittenText(sut: BaseSelectionHandler<String>, input: MockInput, activeIndex: Int = 0, sourceLocation: SourceLocation = #_sourceLocation) {
        let state = sut.state
        let expectedActiveLine = PickerPadding.top + activeIndex

        sut.scrollAndRenderOptions()

        #expect(state.activeLine == expectedActiveLine, "wrong active line", sourceLocation: sourceLocation)

        // Verify header text appears in output
        #expect(input.writtenText.contains(where: { $0.contains(state.topLineText) }), "missing top line text", sourceLocation: sourceLocation)

        // Verify selected item display appears in output (now in header between topLineText and title)
        let selectedItemName = state.options[activeIndex].title
        #expect(input.writtenText.contains(where: { $0.contains("Selected: \(selectedItemName)") }), "missing selected item display", sourceLocation: sourceLocation)

        #expect(input.writtenText.contains(where: { $0.contains(state.title) }), "missing title", sourceLocation: sourceLocation)

        // Verify options appear in output (now 19 instead of 18 since we moved selected item to header and removed separator)
        for i in 0..<19 {
            let indicator = i == activeIndex ? selectedIndicator : unselectedIndicator
            #expect(input.writtenText.contains(where: { $0.contains(indicator) }), "missing indicator for index \(i)", sourceLocation: sourceLocation)
            #expect(input.writtenText.contains(where: { $0.contains(state.options[i].title) }), "missing option \(i)", sourceLocation: sourceLocation)
        }

        // Verify footer text appears in output
        #expect(input.writtenText.contains(where: { $0.contains(state.bottomLineText) }), "missing bottom line text", sourceLocation: sourceLocation)
    }
}
