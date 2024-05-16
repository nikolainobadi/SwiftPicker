//
//  PickerComposer.swift
//
//
//  Created by Nikolai Nobadi on 5/16/24.
//

enum PickerComposer {
    static var inputHandler: PickerInput = PickerInputAdapter()
}


// MARK: - Composer
extension PickerComposer {
    static func makeSingleSelectionHandler<Item: DisplayablePickerItem>(info: PickerInfo<Item>, newScreen: Bool) -> SingleSelectionHandler<Item> {
        configureScreen(newScreen)
        let state = makeState(info: info)
        
        return .init(padding: info.padding, state: state, inputHandler: inputHandler)
    }
    
    static func makeMultiSelectionHandler<Item: DisplayablePickerItem>(info: PickerInfo<Item>, newScreen: Bool) -> MultiSelectionHandler<Item> {
        configureScreen(newScreen)
        let state = makeState(info: info)
        
        return .init(padding: info.padding, state: state, inputHandler: inputHandler)
    }
}


// MARK: - Private Methods
private extension PickerComposer {
    static func configureScreen(_ newScreen: Bool) {
        if newScreen {
            inputHandler.enterAlternativeScreen()
        }
        
        inputHandler.clearScreen()
        inputHandler.moveToHome()
    }
    
    static func makeState<Item: DisplayablePickerItem>(info: PickerInfo<Item>) -> SelectionState<Item> {
        let topLine = inputHandler.readCursorPos().row + info.padding.top
        let options = makeOptions(items: info.items, topLine: topLine)
        
        return .init(options: options, topLine: topLine, title: info.title)
    }
    
    static func makeOptions<Item: DisplayablePickerItem>(items: [Item], topLine: Int) -> [Option<Item>] {
        return items.enumerated().map { .init(item: $1, line: topLine + $0) }
    }
}
