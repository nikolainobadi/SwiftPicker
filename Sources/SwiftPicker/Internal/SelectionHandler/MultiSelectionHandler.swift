//
//  MultiSelectionHandler.swift
//
//
//  Created by Nikolai Nobadi on 5/16/24.
//

internal final class MultiSelectionHandler<Item: DisplayablePickerItem>: BaseSelectionHandler<Item> {
    func captureUserInput() -> [Item] {
        scrollAndRenderOptions()
        while true {
            inputHandler.clearBuffer()
            if inputHandler.keyPressed() {
                if let char = inputHandler.readSpecialChar() {
                    switch char {
                    case .enter:
                        return state.selectedOptions.map({ $0.item })
                    case .space:
                        state.toggleSelection(at: state.activeLine)
                        scrollAndRenderOptions()
                    }
                }
                
                handleArrowKeys()
            }
        }
    }
    
    func printResults(_ selections: [String]) {
        print("\nSwiftPicker MultiSelection results:\n")
        selections.forEach({ print("  \("✔".green) \($0)") })
        print("")
    }
}
