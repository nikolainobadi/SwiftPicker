//
//  SwiftPicker.swift
//
//
//  Created by Nikolai Nobadi on 5/16/24.
//

public struct SwiftPicker {
    public let padding: PickerPadding
    
    public init(padding: PickerPadding = .init()) {
        self.padding = padding
    }
}


// MARK: - SingleSelection
public extension SwiftPicker {
    func requiredSingleSelection<Item: DisplayablePickerItem>(title: String, items: [Item]) throws -> Item {
        guard let selection = singleSelection(title: title, items: items) else {
            throw SwiftPickerError.selectionCancelled
        }
        
        return selection
    }
    
    func singleSelection<Item: DisplayablePickerItem>(title: String, items: [Item]) -> Item? {
        let info = makeInfo(title: title, items: items)
        
        return captureSingleInput(info: info, showNewScreen: true)
    }
}


// MARK: - Private Methods
private extension SwiftPicker {
    func makeInfo<Item: DisplayablePickerItem>(title: String, items: [Item]) -> PickerInfo<Item> {
        return .init(title: title, items: items, padding: padding)
    }
    func captureSingleInput<Item: DisplayablePickerItem>(info: PickerInfo<Item>, showNewScreen: Bool) -> Item? {
        let handler = PickerComposer.makeSingleSelectionPicker(info: info, newScreen: showNewScreen)
        let selection = handler.captureUserInput()
        
        handler.endSelection()
        handler.printResult(selection?.displayName)
        
        return selection
    }
}
