# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SwiftPicker is a Swift Package Manager library that provides interactive command-line picker functionality for Swift applications. It supports single and multiple item selection with terminal-based UI using ANSI escape sequences.

## Architecture

### Core Components

- **`Picker` Protocol** (`Sources/SwiftPicker/PickerFeature/Picker.swift:9`): Main interface defining input, permission, and selection methods
- **`SwiftPicker` Struct** (`Sources/SwiftPicker/PickerFeature/SwiftPicker.swift:10`): Concrete implementation of the `Picker` protocol
- **`DisplayablePickerItem` Protocol** (`Sources/SwiftPicker/PickerFeature/DisplayablePickerItem.swift:10`): Protocol for items that can be displayed in picker lists
- **`PickerPrompt` Protocol** (`Sources/SwiftPicker/PickerFeature/PickerPrompt.swift:8`): Protocol for prompt messages (String conforms by default)

### Internal Architecture

- **PickerComposer** (`Sources/SwiftPicker/Internal/Composer/PickerComposer.swift:10`): Factory class that creates selection handlers and manages state
- **Selection Handlers** (`Sources/SwiftPicker/Internal/SelectionHandler/`): 
  - `BaseSelectionHandler`: Abstract base class for selection logic
  - `SingleSelectionHandler`: Handles single item selection
  - `MultiSelectionHandler`: Handles multiple item selection
- **Input System** (`Sources/SwiftPicker/Internal/Input/`):
  - `PickerInput` protocol and `PickerInputAdapter`: Terminal input abstraction
  - `InputHandler`: Static methods for basic input operations
- **Models** (`Sources/SwiftPicker/Internal/Models/`): Core data structures including `Option`, `PickerInfo`, `SelectionState`

### Dependencies

- **ANSITerminal** (from ANSITerminalModified package): Provides terminal control and ANSI escape sequence support

## Development Commands

### Building
```bash
swift build
```

### Testing
```bash
swift test
```

### Running Single Test
```bash
swift test --filter <TestClassName>.<testMethodName>
```

### Package Resolution
```bash
swift package resolve
swift package update
```

## Testing Architecture

- **XCTest-based**: Uses standard Swift testing framework
- **Mock Input System**: `MockInput` class in tests provides controllable input simulation
- **Integration Tests**: `IntegrationTests.swift` tests full picker workflows with mock input
- **Unit Tests**: `BaseSelectionHandlerTests.swift` tests individual components

### Key Test Patterns
- Tests use `makeSUT()` helper methods to create system under test with mock dependencies
- Mock input allows queuing special characters (enter, space, arrows) and simulating key presses
- Tests verify both selection logic and terminal state management

## Code Conventions

- **Access Control**: Public APIs in `PickerFeature/`, internal implementation in `Internal/`
- **Protocol-Oriented Design**: Heavy use of protocols (`Picker`, `DisplayablePickerItem`, `PickerPrompt`, `PickerInput`)
- **Generic Constraints**: Selection methods use `<Item: DisplayablePickerItem>` generic constraints
- **Error Handling**: Custom `SwiftPickerError` enum for picker-specific errors
- **Extension Organization**: Public API methods organized in separate extensions by functionality (Input, Permission, SingleSelection, MultiSelection)

## Platform Requirements

- **macOS 10.14+** minimum deployment target
- **Swift 5.0+** toolchain requirement
- **Terminal environment** required for ANSI escape sequence support