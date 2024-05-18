
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


### Single Selection
![Single Selection Demo](Media/single-select-demo.gif)

```swift
import SwiftPicker

let picker = SwiftPicker()
let title = "Choose Your Favorite Programming Language"
let sampleList = ["Swift", "Python", "JavaScript", "C#", "Java", "Go", "Ruby", "Kotlin"]

if let selection = picker.singleSelection(title: title, items: sampleList) {        print("You selected: \(selection.displayName)")
} else {
    print("No selection made.")
}

let selections = picker.multiSelection(title: title, items: sampleList)

print("You selected: \(selections.map { $0.displayName })")

```

### Multi-Selection
![Multiple Selection Demo](media/multi-select-demo.gif)

To use custom items in SwiftPicker, conform your type to the `DisplayablePickerItem` protocol. And don't worry about long lists, SwiftPicker can handle scrolling!

```swift
struct Movie {
    let title: String
    let director: String
}

// customize the 'displayName' 
extension Movie: DisplayablePickerItem {
    var displayName: String {
        return title
    }
}

let marvelMovies = Movie.marvelList
let title = "Select Your Favorite Marvel Movies."
let results = picker.multiSelection(title: title, items: marvelMovies)
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
