//
//  SelectionState.swift
//
//
//  Created by Nikolai Nobadi on 5/14/24.
//

internal final class SelectionState<Item: DisplayablePickerItem> {
    let topLine: Int
    let title: String
    var activeLine: Int
    var options: [Option<Item>]
    
    init(options: [Option<Item>], topLine: Int, title: String) {
        self.title = title
        self.options = options
        self.topLine = topLine
        self.activeLine = topLine
    }
}


// MARK: - Helper Methods
extension SelectionState {
    var selectedOptions: [Option<Item>] {
        return options.filter({ $0.isSelected })
    }
    
    var rangeOfLines: (minimum: Int, maximum: Int) {
        return (topLine, topLine + options.count - 1)
    }
    
    func toggleSelection(at line: Int) {
        if let activeIndex = options.firstIndex(where: { $0.line == line }) {
            options[activeIndex].isSelected.toggle()
        }
    }
}
