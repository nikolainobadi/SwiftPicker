//
//  SingleSelectionHandler.swift
//  
//
//  Created by Nikolai Nobadi on 5/16/24.
//

internal final class SingleSelectionHandler<Item: DisplayablePickerItem>: BaseSelectionHandler<Item> {
    func captureUserInput() -> Item? {
        scrollAndRenderOptions()
        while true {
            inputHandler.clearBuffer()
            if inputHandler.keyPressed() {
                if let char = inputHandler.readSpecialChar(), char == .enter {
                    return state.options.first(where: { $0.line == state.activeLine })?.item
                }
                
                handleArrowKeys()
            }
        }
    }
    
    func printResult(_ selection: String?) {
        if let selection {
            print("\nSwiftPicker SingleSelection result:\n  \("✔".green) \(selection)\n")
        }
    }
}
