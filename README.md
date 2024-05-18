# SwiftPicker
![](https://badgen.net/badge/Swift/5+/orange)
![](https://badgen.net/badge/platform/macos?list=|&color=grey)
![](https://badgen.net/badge/distro/SPM%20only?color=red)
![](https://badgen.net/badge/license/MIT/blue)

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

if let selection = picker.singleSelection(title: title, items: sampleList) {
    // do what you want with the selction
}
```

### Multi-Selection
To use custom items in SwiftPicker, conform your type to the `DisplayablePickerItem` protocol. And don't worry about long lists, SwiftPicker can handle scrolling!

![Multiple Selection Demo](Media/multi-select-demo.gif)

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
## Backstory
I think programming is one of the few fields where 'specialized laziness' is actually a superpower. While building custom command line tools may seem like a daunting task to some, I see it as a way to never have to waste time on the boring portions of my workflow ever again. But I'm an iOS developer. When I write code, I prefer to do it in Swift. Unfortunately, there aren't many Swift libraries for command line tools. And I feel like it's a catch-22 because nobody wants to write libraries for the command line using Swift because there aren't many libraries out there to help them, and there aren't many libraries out there because nobody wants to write them, and round and round we go.

SwiftPicker is simply my contribution to the (hopefully growing) ecosystem of Swift command line tools. It's easy to use, relatively lightweight, and best of all, it helps me write more command line tools to feed my 'specialized laziness'.

## Acknowledgements

This project was inspired by [How to Make an Interactive Picker for a Swift Command-Line Tool](https://www.polpiella.dev/how-to-make-an-interactive-picker-for-a-swift-command-line-tool/) by Pol Piella Abadia. Special thanks for the great tutorial.

## Contributing
Any feedback or ideas to enhance SwiftPicker would be well received. Please feel free to [open an issue](https://github.com/nikolainobadi/SwiftPicker/issues/new) if you'd like to help improve this swift package.

## License

SwiftPicker is released under the MIT License. See [LICENSE](LICENSE) for details.
