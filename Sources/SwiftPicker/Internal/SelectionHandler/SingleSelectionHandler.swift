//
//  SingleSelectionHandler.swift
//  
//
//  Created by Nikolai Nobadi on 5/16/24.
//

/// A class for handling single selection logic in InteractivePicker.
/// It captures the user's single selection from the list of options.
internal final class SingleSelectionHandler<Item: DisplayablePickerItem>: BaseSelectionHandler<Item> {
    /// Captures the user's input for a single selection.
    /// - Returns: The selected item, or `nil` if no selection was made.
    func captureUserInput() -> Item? {
        scrollAndRenderOptions()
        while true {
            inputHandler.clearBuffer()
            if inputHandler.keyPressed() {
                if let char = inputHandler.readSpecialChar() {
                    switch char {
                    case .enter:
                        return state.options.first(where: { $0.line == state.activeLine })?.item
                    case .quit:
                        return nil
                    case .space:
                        continue
                    }
                }
                
                handleArrowKeys()
            }
        }
    }
    
    /// Prints the result of the single selection.
    /// - Parameter selection: The selected item, or `nil` if no selection was made.
    func printResult(_ selection: String?) {
        if let selection {
            print("\nInteractivePicker SingleSelection result:\n  \("✔".green) \(selection)")
            print("")
        }
    }
}
