//
//  SelectionState.swift
//
//
//  Created by Nikolai Nobadi on 5/14/24.
//

internal final class SelectionState {
    /// The top line for rendering the options
    let topLine: Int
    
    /// The bottom line for rendering the options
    let bottomLine: Int
    
    /// All the available options for selection
    var options: [Option]
    
    /// The line number that is currently active or highlighted
    var activeLine: Int = .zero
    
    /// Initializes a new `SelectionState` object.
    ///
    /// - Parameters:
    ///   - options: An array containing the options that can be selected.
    ///   - topLine: The top line number where the options start being rendered.
    ///   - bottomLine: The bottom line number where the options end being rendered.
    init(options: [Option], topLine: Int, bottomLine: Int) {
        self.topLine = topLine
        self.bottomLine = bottomLine
        self.activeLine = topLine
        self.options = options
    }
}


// MARK: - Helper Methods
extension SelectionState {
    /// Returns the options that have been selected.
    var selectedOptions: [Option] {
        return options.filter({ $0.isSelected })
    }
    
    /// Returns the range of line numbers that can be active.
    var rangeOfLines: (minimum: Int, maximum: Int) {
        return (topLine, topLine + options.count - 1)
    }
    
    /// Toggles the selection state of the option at the given line.
    ///
    /// - Parameter line: The line number of the option to toggle.
    func toggleSelection(at line: Int) {
        if let activeIndex = options.firstIndex(where: { $0.line == line }) {
            options[activeIndex].isSelected.toggle()
        }
    }
}
