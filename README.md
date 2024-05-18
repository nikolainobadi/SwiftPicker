
# SwiftPicker

SwiftPicker is a command-line picker tool written in Swift. It allows users to interactively select single or multiple items from a list using a text-based interface.

## Features

- Single and multiple item selection.
- User-friendly prompts for input and permission.
- ANSI terminal support for enhanced UI.
- Customizable with any type conforming to `DisplayablePickerItem`.

## Installation

To use SwiftPicker in your Swift project, add it as a dependency in your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/nikolainobadi/SwiftPicker.git", from: "0.8.0")
]
```

Then import it in your project:

```swift
import SwiftPicker
```

## Usage

### Basic Example

```swift
import SwiftPicker

let picker = SwiftPicker()
let title = "Select the items that you would like to use."
let sampleList = (1...25).map { "Item \($0)" }

if let selection = picker.singleSelection(title: title, items: sampleList) {        print("You selected: \(selection.displayName)")
} else {
    print("No selection made.")
}

let selections = picker.multiSelection(title: title, items: sampleList)

print("You selected: \(selections.map { $0.displayName })")

```

### Custom Items

To use custom items in SwiftPicker, conform your type to the `DisplayablePickerItem` protocol:

```swift
struct CustomItem {
    let itemName: String
}

// customize the 'displayName' 
extension CustomItem: DisplayablePickerItem {
    var displayName: String {
        return itemName
    }
}

let customItems = [CustomItem(displayName: "Custom 1"), CustomItem(displayName: "Custom 2")]
let title = "Select a custom item."

if let customSelection = picker.singleSelection(title: title, items: customItems) {
    print("You selected: \(customSelection.displayName)")
}
```

### Error Handling

SwiftPicker can throw errors which you may handle using `do-catch`:

```swift
do {
    let input = try picker.getRequiredInput("Please provide input:")
    print("Your input: \(input)")
} catch {
    print("Input is required.")
}

do {
    let selection = try picker.requiredSingleSelection(title: title, items: sampleList)
    print("You selected: \(selection.displayName)")
} catch SwiftPickerError.selectionCancelled {
    print("Selection was cancelled.")
} catch {
    print("An unknown error occurred.")
}
```

## Acknowledgements

This project was inspired by [How to Make an Interactive Picker for a Swift Command-Line Tool](https://www.polpiella.dev/how-to-make-an-interactive-picker-for-a-swift-command-line-tool/) by Pol Piella Abadia. Special thanks for the great tutorial.

## License

SwiftPicker is released under the MIT License. See [LICENSE](LICENSE) for details.
