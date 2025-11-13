//
//  MultiSelectionHandler.swift
//
//
//  Created by Nikolai Nobadi on 5/16/24.
//

/// A class for handling multi-selection logic in `InteractivePicker`.
/// It captures the user's multiple selections from the list of options.
final class MultiSelectionHandler<Item: DisplayablePickerItem>: BaseSelectionHandler<Item> {
    /// Captures the user's input for multiple selections.
    /// - Returns: An array of selected items.
    func captureUserInput() -> [Item] {
        // Set up signal handlers to ensure terminal cleanup on interrupt
        SignalHandler.setupSignalHandlers { [inputHandler] in
            inputHandler.exitAlternativeScreen()
            inputHandler.enableNormalInput()
        }

        defer {
            SignalHandler.removeSignalHandlers()
            endSelection()
        }

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
                    case .quit:
                        return []
                    case .backspace:
                        continue  // No action for backspace in multi selection
                    }
                }

                handleArrowKeys()
            }
        }
    }
    
    /// Prints the results of the multi-selection.
    /// - Parameter selections: An array of selected item display names.
    func printResults(_ selections: [String]) {
        guard !selections.isEmpty else { return }
        print("\nInteractivePicker MultiSelection results:\n")
        selections.forEach({ print(" \("✔".green) \($0)") })
        print("")
    }
}
