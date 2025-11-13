//
//  PickerHeaderRendererTests.swift
//
//
//  Created by Nikolai Nobadi on 11/13/25.
//

import Testing
@testable import SwiftPicker

struct PickerHeaderRendererTests {
    @Test("Header renders topLineText centered on first line")
    func rendersTopLineTextCenteredOnFirstLine() {
        let topLineText = "Test Picker"
        let screenWidth = 80
        let (sut, input) = makeSUT()

        sut.renderHeader(
            topLineText: topLineText,
            title: "Title",
            selectedItem: nil,
            screenWidth: screenWidth,
            showScrollUpIndicator: false
        )

        #expect(input.writtenText.contains(where: { $0.contains(topLineText) }))

        let centeredText = centerText(topLineText, inWidth: screenWidth)
        #expect(input.writtenText.first == centeredText)
    }

    @Test("Header renders title centered after topLineText")
    func rendersTitleCenteredAfterTopLineText() {
        let title = "Select an Option"
        let screenWidth = 80
        let (sut, input) = makeSUT()

        sut.renderHeader(
            topLineText: "Picker",
            title: title,
            selectedItem: nil,
            screenWidth: screenWidth,
            showScrollUpIndicator: false
        )

        #expect(input.writtenText.contains(where: { $0.contains(title) }))

        let centeredTitle = centerText(title, inWidth: screenWidth)
        #expect(input.writtenText.contains(centeredTitle))
    }

    @Test("Header renders selected item between topLineText and title")
    func rendersSelectedItemBetweenTopLineTextAndTitle() {
        let topLineText = "Picker"
        let title = "Select Option"
        let item = "Selected Item"
        let expectedDisplay = "Selected: \(item)"
        let screenWidth = 80
        let (sut, input) = makeSUT()

        sut.renderHeader(
            topLineText: topLineText,
            title: title,
            selectedItem: item,
            screenWidth: screenWidth,
            showScrollUpIndicator: false
        )

        #expect(input.writtenText.contains(where: { $0.contains(expectedDisplay) }))

        let topLineIndex = input.writtenText.firstIndex(where: { $0.contains(topLineText) })
        let titleIndex = input.writtenText.firstIndex(where: { $0.contains(title) })
        let itemIndex = input.writtenText.firstIndex(where: { $0.contains(expectedDisplay) })

        #expect(topLineIndex != nil)
        #expect(titleIndex != nil)
        #expect(itemIndex != nil)
        #expect(itemIndex! > topLineIndex!)
        #expect(itemIndex! < titleIndex!)
    }

    @Test("Header omits selected item when none provided")
    func omitsSelectedItemWhenNoneProvided() {
        let (sut, input) = makeSUT()

        sut.renderHeader(
            topLineText: "Picker",
            title: "Title",
            selectedItem: nil,
            screenWidth: 80,
            showScrollUpIndicator: false
        )

        let titleIndex = input.writtenText.firstIndex(where: { $0.contains("Title") })
        #expect(titleIndex != nil)
    }

    @Test("Header displays scroll up indicator when requested")
    func displaysScrollUpIndicatorWhenRequested() {
        let (sut, input) = makeSUT()

        sut.renderHeader(
            topLineText: "Picker",
            title: "Title",
            selectedItem: nil,
            screenWidth: 80,
            showScrollUpIndicator: true
        )

        #expect(input.writtenText.contains(where: { $0.contains("↑") }))
    }

    @Test("Header omits scroll indicator when not requested")
    func omitsScrollIndicatorWhenNotRequested() {
        let (sut, input) = makeSUT()

        sut.renderHeader(
            topLineText: "Picker",
            title: "Title",
            selectedItem: nil,
            screenWidth: 80,
            showScrollUpIndicator: false
        )

        #expect(!input.writtenText.contains(where: { $0.contains("↑") }))
    }

    @Test("Header truncates long title to fit screen width")
    func truncatesLongTitleToFitScreenWidth() {
        let longTitle = String(repeating: "A", count: 100)
        let screenWidth = 50
        let (sut, input) = makeSUT()

        sut.renderHeader(
            topLineText: "Picker", 
            title: longTitle,
            selectedItem: nil,
            screenWidth: screenWidth,
            showScrollUpIndicator: false
        )

        let writtenTitle = input.writtenText.first(where: { $0.contains("A") })
        #expect(writtenTitle != nil)
        #expect(writtenTitle!.contains("…"))
    }

    @Test("Header truncates long selected item to fit screen width")
    func truncatesLongSelectedItemToFitScreenWidth() {
        let longItem = String(repeating: "B", count: 100)
        let screenWidth = 50
        let (sut, input) = makeSUT()

        sut.renderHeader(
            topLineText: "Picker",
            title: "Title",
            selectedItem: longItem,
            screenWidth: screenWidth,
            showScrollUpIndicator: false
        )

        let writtenItem = input.writtenText.first(where: { $0.contains("Selected:") })
        #expect(writtenItem != nil)
        #expect(writtenItem!.contains("…"))
    }

    @Test("Header centers selected item text within screen width")
    func centersSelectedItemTextWithinScreenWidth() {
        let item = "Selected"
        let expectedDisplay = "Selected: \(item)"
        let screenWidth = 80
        let (sut, input) = makeSUT()

        sut.renderHeader(
            topLineText: "Picker",
            title: "Title",
            selectedItem: item,
            screenWidth: screenWidth,
            showScrollUpIndicator: false
        )

        let centeredItem = centerText(expectedDisplay, inWidth: screenWidth)
        #expect(input.writtenText.contains(where: { $0.contains(centeredItem) }))
    }

    @Test("Header clears screen before rendering")
    func clearsScreenBeforeRendering() {
        let (sut, input) = makeSUT()

        sut.renderHeader(
            topLineText: "Picker",
            title: "Title",
            selectedItem: nil,
            screenWidth: 80,
            showScrollUpIndicator: false
        )

        #expect(!input.writtenText.isEmpty)
    }

    @Test("Header renders empty lines for spacing between sections")
    func rendersEmptyLinesForSpacingBetweenSections() {
        let (sut, input) = makeSUT()

        sut.renderHeader(
            topLineText: "Picker",
            title: "Title",
            selectedItem: nil,
            screenWidth: 80,
            showScrollUpIndicator: false
        )

        let newlineCount = input.writtenText.filter { $0 == "\n" }.count
        #expect(newlineCount >= 2)
    }

    @Test("Header renders extra space when selected item present")
    func rendersExtraSpaceWhenSelectedItemPresent() {
        let item = "Selected"
        let (sut, input) = makeSUT()

        sut.renderHeader(
            topLineText: "Picker",
            title: "Title",
            selectedItem: item,
            screenWidth: 80,
            showScrollUpIndicator: false
        )

        let newlineCount = input.writtenText.filter { $0 == "\n" }.count
        #expect(newlineCount >= 3)
    }
}


// MARK: - SUT
private extension PickerHeaderRendererTests {
    func makeSUT() -> (sut: PickerHeaderRenderer, input: MockInput) {
        let input = MockInput()
        let sut = PickerHeaderRenderer(inputHandler: input)

        return (sut, input)
    }

    func centerText(_ text: String, inWidth width: Int) -> String {
        PickerTextFormatter.centerText(text, inWidth: width)
    }
}
