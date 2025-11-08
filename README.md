# SwiftPicker
![Unit Tests](https://github.com/nikolainobadi/SwiftPicker/actions/workflows/ci.yml/badge.svg)
![](https://badgen.net/badge/Swift/5.9+/orange)
![](https://badgen.net/badge/platform/macos?list=|&color=grey)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

SwiftPicker is a Swift Package Manager library that provides interactive command-line picker functionality for Swift applications. It supports single and multiple item selection with terminal-based UI using ANSI escape sequences.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Protocol Architecture](#protocol-architecture)
- [Usage Examples](#usage-examples)
  - [Single Selection](#single-selection)
  - [Multi-Selection](#multi-selection)
  - [Column Selection](#column-selection)
  - [Error Handling](#error-handling)
- [Backstory](#backstory)
- [Testing](#testing)
- [Acknowledgements](#acknowledgements)
- [Contributing](#contributing)
- [License](#license)

## Features

- **Single & Multiple Selection**: Interactive selection from lists with keyboard navigation
- **Column Selection**: Multi-column navigation with horizontal and vertical browsing
- **Protocol-Oriented Design**: Flexible architecture with composable protocols
- **Custom Types**: Any type can conform to `DisplayablePickerItem` for picker support
- **Input & Permission Handling**: Built-in text input and yes/no confirmation methods
- **ANSI Terminal Support**: Enhanced UI with cursor control and screen management
- **Error Handling**: Comprehensive error handling with `SwiftPickerError` enum
- **Modern Swift**: Built with Swift 5.9+ using contemporary patterns
- **Comprehensive Testing**: 109 tests ensuring reliability and behavior validation

## Installation

To use SwiftPicker in your Swift project, add it as a dependency in your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/nikolainobadi/SwiftPicker.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["SwiftPicker"]
    ),
    .testTarget(
        name: "YourTestTarget",
        dependencies: [
            "YourTarget",
            .product(name: "SwiftPickerTesting", package: "SwiftPicker")  // For testing
        ]
    )
]
```

### SwiftPickerTesting

SwiftPicker includes a dedicated testing library (`SwiftPickerTesting`) that provides `MockSwiftPicker` for unit testing code that depends on command-line interaction without requiring actual terminal I/O.

## Quick Start

```swift
import SwiftPicker

// Create a picker instance
let picker = InteractivePicker()

// Simple text input
let name = picker.getInput(prompt: "What's your name?")
print("Hello, \(name)!")

// Yes/no confirmation
if picker.getPermission(prompt: "Continue?") {
    // User confirmed
}

// Single selection
let colors = ["Red", "Green", "Blue"]
if let color = picker.singleSelection(title: "Pick a color:", items: colors) {
    print("You chose: \(color)")
}

// Multiple selection
let hobbies = ["Reading", "Gaming", "Cooking", "Sports"]
let selected = picker.multiSelection(title: "Your hobbies:", items: hobbies)
print("Selected \(selected.count) hobbies")

// Column selection
let folders = ["Documents", "Downloads", "Pictures"]
let files = ["report.pdf", "data.csv", "photo.jpg"]
let columns = [
    PickerColumn(title: "Folders", items: folders),
    PickerColumn(title: "Files", items: files)
]
if let selection = picker.columnSelection(columns: columns, title: "Browse Files") {
    print("You selected: \(selection)")
}
```

## Protocol Architecture

SwiftPicker uses a protocol-oriented design for maximum flexibility:

```swift
// Unified interface combining all capabilities
let picker: CommandLinePicker = InteractivePicker()

// Or use individual protocol capabilities
let inputHandler: CommandLineInput = picker
let permissionHandler: CommandLinePermission = picker
let selectionHandler: CommandLineSelection = picker
```

### Core Protocols

- **`CommandLinePicker`**: Composition of all command-line interaction protocols
- **`CommandLineInput`**: Text input methods (`getInput`, `getRequiredInput`)
- **`CommandLinePermission`**: Yes/no confirmation methods (`getPermission`, `requiredPermission`)
- **`CommandLineSelection`**: Single/multi selection methods (`singleSelection`, `requiredSingleSelection`, `multiSelection`)
- **`DisplayablePickerItem`**: Items that can be displayed (requires `displayName: String`)
- **`PickerPrompt`**: Prompt messages (requires `title: String`)

### Backward Compatibility

For existing code, deprecated aliases are available:

```swift
// Deprecated but still functional
let picker: Picker = InteractivePicker()  // Use CommandLinePicker instead
let oldPicker = SwiftPicker()             // Use InteractivePicker() instead
```

## Usage Examples


### Single Selection
![Single Selection Demo](Media/single-select-demo.gif)

```swift
import SwiftPicker

// Use the modern InteractivePicker struct
let picker = InteractivePicker()
let title = "Choose Your Favorite Programming Language"
let sampleList = ["Swift", "Python", "JavaScript", "C#", "Java", "Go", "Ruby", "Kotlin"]

// Select a single item
if let selection = picker.singleSelection(title: title, items: sampleList) {
    print("You selected: \(selection)")
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

// Conform to DisplayablePickerItem protocol
extension Movie: DisplayablePickerItem {
    var displayName: String {
        return "\(title) (\(director))"
    }
}

let marvelMovies = [
    Movie(title: "Iron Man", director: "Jon Favreau"),
    Movie(title: "The Avengers", director: "Joss Whedon"),
    Movie(title: "Black Panther", director: "Ryan Coogler")
]

let title = "Select Your Favorite Marvel Movies"
let results = picker.multiSelection(title: title, items: marvelMovies)
print("Selected \(results.count) movies")
```

### Column Selection

Navigate through multiple columns with horizontal (←→) and vertical (↑↓) arrow keys:

```swift
import SwiftPicker

let picker = InteractivePicker()

// Create columns with different categories
let folders = ["Documents", "Downloads", "Desktop", "Pictures"]
let files = ["report.pdf", "data.csv", "notes.txt", "photo.jpg"]
let actions = ["Open", "Copy", "Move", "Delete"]

let columns = [
    PickerColumn(title: "Folders", items: folders),
    PickerColumn(title: "Files", items: files),
    PickerColumn(title: "Actions", items: actions)
]

// User can navigate horizontally between columns and vertically within them
if let selection = picker.columnSelection(columns: columns, title: "File Browser") {
    print("Selected: \(selection)")
} else {
    print("Selection cancelled")
}

// Column selection also works with custom types
struct FileItem: DisplayablePickerItem {
    let name: String
    let size: String

    var displayName: String { "\(name) (\(size))" }
}

let documents = [
    FileItem(name: "Report.pdf", size: "2.4 MB"),
    FileItem(name: "Presentation.pptx", size: "5.1 MB")
]

let images = [
    FileItem(name: "Photo1.jpg", size: "1.2 MB"),
    FileItem(name: "Photo2.png", size: "3.5 MB")
]

let fileColumns = [
    PickerColumn(title: "Documents", items: documents),
    PickerColumn(title: "Images", items: images)
]

if let file = picker.columnSelection(columns: fileColumns, title: "Select File") {
    print("Selected: \(file.name) - \(file.size)")
}
```

#### Dynamic Column Navigation

For more complex hierarchies, use the `onNavigate` closure to load child items on demand:

```swift
struct Folder: DisplayablePickerItem {
    let name: String
    let path: String

    var displayName: String { name }
}

let rootFolders = [
    Folder(name: "Documents", path: "/Documents"),
    Folder(name: "Downloads", path: "/Downloads")
]

let columns = [PickerColumn(title: "Folders", items: rootFolders)]

// Press Space on any folder to navigate into it
let selection = picker.columnSelection(
    columns: columns,
    title: "File Browser",
    onNavigate: { folder in
        // Load children for the selected folder
        let children = loadSubfolders(at: folder.path)
        return children.isEmpty ? nil : (items: children, title: folder.name)
    }
)

if let selectedFolder = selection {
    print("Selected: \(selectedFolder.path)")
}
```

**Navigation:**
- **←→ arrows**: Switch between columns
- **↑↓ arrows**: Navigate items within the active column
- **Space**: Navigate into an item to load children (when using `onNavigate`)
- **Backspace**: Go back to parent level
- **Enter**: Select the active item
- **Q**: Quit without selecting

**Features:**
- **Breadcrumb navigation**: Automatically displays the navigation path (e.g., "Documents > Reports > 2024")
- **Dynamic loading**: Use the `onNavigate` closure to load child items on demand
- **Text truncation**: Long column titles and item names are automatically truncated to fit

### Error Handling

SwiftPicker provides throwing methods for required inputs and selections:

```swift
// Required text input with validation
do {
    let input = try picker.getRequiredInput(prompt: "Please provide your name:")
    print("Hello, \(input)!")
} catch SwiftPickerError.inputRequired {
    print("Input cannot be empty.")
}

// Required permission (throws if user denies)
do {
    try picker.requiredPermission(prompt: "Do you want to continue?")
    print("Proceeding...")
} catch SwiftPickerError.selectionCancelled {
    print("Operation cancelled.")
}

// Required selection (throws if user quits)
do {
    let languages = ["Swift", "Python", "JavaScript"]
    let selection = try picker.requiredSingleSelection(title: "Choose a language:", items: languages)
    print("You selected: \(selection)")
} catch SwiftPickerError.selectionCancelled {
    print("No selection made.")
}

// Optional selection (returns nil on quit, no error)
let colors = ["Red", "Green", "Blue"]
if let color = picker.singleSelection(title: "Pick a color:", items: colors) {
    print("Selected: \(color)")
} else {
    print("No selection made.")
}
```
## Backstory
I think programming is one of the few fields where 'specialized laziness' is actually a superpower. While building custom command line tools may seem like a daunting task to some, I see it as a way to never have to waste time on the boring portions of my workflow ever again. But I'm an iOS developer. When I write code, I prefer to do it in Swift. Unfortunately, there aren't many Swift libraries for command line tools. And I feel like it's a catch-22 because nobody wants to write libraries for the command line using Swift because there aren't many libraries out there to help them, and there aren't many libraries out there because nobody wants to write them, and round and round we go.

SwiftPicker is simply my contribution to the (hopefully growing) ecosystem of Swift command line tools. It's easy to use, relatively lightweight, and best of all, it helps me write more command line tools to feed my 'specialized laziness'.

## Testing

### MockSwiftPicker for Unit Testing

The `SwiftPickerTesting` library provides `MockSwiftPicker`, a configurable mock implementation for testing code that depends on user interaction:

```swift
import Testing
import SwiftPickerTesting

@Test("User flow with multiple interactions")
func testUserFlow() {
    // Configure mock with pre-defined responses
    let mock = MockSwiftPicker(
        inputResult: .init(type: .ordered(["Alice", "alice@example.com"])),
        permissionResult: .init(type: .ordered([true, false])),
        selectionResult: .init(singleSelectionType: .ordered([1]))
    )

    // Test your code that uses the picker
    let name = mock.getInput(prompt: "Name:")  // Returns "Alice"
    let email = mock.getInput(prompt: "Email:")  // Returns "alice@example.com"
    let canContinue = mock.getPermission(prompt: "Continue?")  // Returns true
    let canDelete = mock.getPermission(prompt: "Delete?")  // Returns false

    let items = ["Red", "Green", "Blue"]
    let color = mock.singleSelection(title: "Color:", items: items)  // Returns "Green" (index 1)

    // Verify behavior
    #expect(name == "Alice")
    #expect(color == "Green")
}
```

**Key Features:**
- **Ordered Responses**: Queue responses that are consumed in sequence (FIFO)
- **Dictionary Responses**: Map responses to specific prompts by title
- **Default Fallbacks**: Configure default values when queues are exhausted
- **Error Testing**: Simulate cancellations and invalid inputs
- **Multi-Selection**: Support for testing multiple item selections with configurable indices

See `MockSwiftPicker` inline documentation for comprehensive usage examples and API details.

## Acknowledgements

This project was inspired by [How to Make an Interactive Picker for a Swift Command-Line Tool](https://www.polpiella.dev/how-to-make-an-interactive-picker-for-a-swift-command-line-tool/) by Pol Piella Abadia. Special thanks for the great tutorial.

## Contributing
Any feedback or ideas to enhance SwiftPicker would be well received. Please feel free to [open an issue](https://github.com/nikolainobadi/SwiftPicker/issues/new) if you'd like to help improve this swift package.

## License

SwiftPicker is released under the MIT License. See [LICENSE](LICENSE) for details.
