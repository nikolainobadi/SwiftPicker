# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SwiftPicker is a Swift Package Manager library that provides interactive command-line picker functionality for Swift applications. It supports single and multiple item selection with terminal-based UI using ANSI escape sequences.

## Architecture

### Module Organization

The codebase is organized into three main modules:
- **API/** - Public interface and protocols
- **Engine/** - Core selection logic and state management
- **IO/** - Terminal input/output handling

### API Module (`Sources/SwiftPicker/API/`)

- **`CommandLinePicker` Protocol** (`API/Typealiases/CommandLinePicker.swift`): Unified interface combining input, permission, and selection capabilities through protocol composition
- **Protocol Architecture** (`API/Protocols/`):
  - `CommandLineInput`: Text input methods (`getInput`, `getRequiredInput`)
  - `CommandLinePermission`: Yes/no permission methods (`getPermission`)
  - `CommandLineSelection`: Single/multi selection methods (`selectSingleItem`, `selectMultipleItems`)
  - `DisplayablePickerItem`: Items that can be displayed in picker lists (requires `displayName: String`)
  - `PickerPrompt`: Prompt messages (requires `title: String`, String conforms by default)
- **`InteractivePicker` Struct** (`API/Picker/InteractivePicker.swift`): Concrete implementation of `CommandLinePicker` (renamed from `SwiftPicker`)
- **`SwiftPickerError` Enum** (`API/Errors/SwiftPickerError.swift`): Custom errors (`selectionCancelled`, `inputRequired`)

### Engine Module (`Sources/SwiftPicker/Engine/`)

- **SelectionHandlerFactory** (`Engine/Factory/SelectionHandlerFactory.swift`): Factory class that creates selection handlers with dependency injection support (renamed from `PickerComposer`)
  - Default methods: Use static `inputHandler` property
  - Overloaded methods: Accept custom `inputHandler` parameter for testing
- **Core Selection Handlers** (`Engine/Core/`):
  - `BaseSelectionHandler`: Abstract base class for selection logic and terminal management
  - `SingleSelectionHandler`: Handles single item selection (returns item or nil on quit)
  - `MultiSelectionHandler`: Handles multiple item selection (returns empty array on quit)
- **Models** (`Engine/Models/`): Core data structures
  - `Option`: Represents a selectable item with position and state
  - `PickerInfo`: Container for title and items
  - `SelectionState`: Manages active selection state
- **Configuration** (`Engine/Config/`):
  - `PickerPadding`: Top and bottom padding constants

### IO Module (`Sources/SwiftPicker/IO/`)

- **`PickerInput` Protocol** (`IO/PickerInput.swift`): Terminal input abstraction (`readSpecialChar`, `readDirectionKey`, cursor control)
- **`PickerInputAdapter`** (`IO/PickerInputAdapter.swift`): Real terminal implementation using ANSITerminal
- **`InputHandler`** (`IO/InputHandler.swift`): Handles text input and permission prompts
- **Input Types**:
  - `Direction` enum: `.up`, `.down` navigation
  - `SpecialChar` enum: `.enter`, `.space`, `.quit` actions

### Behavioral Notes
- **Quit Behavior**: Single selection returns `nil`, multi-selection returns empty array `[]`
- **Navigation**: Arrow keys handled by `readDirectionKey()`, not `readSpecialChar()`
- **Selection State**: Multi-selection maintains toggle state until enter/quit
- **Terminal Management**: Alternative screen mode, cursor control, input buffering

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

### Framework & Coverage
- **Swift Testing Framework**: Modern testing with behavior-driven descriptions using `@Test` attributes
- **Comprehensive Coverage**: 52+ tests across multiple test suites covering all major functionality
- **Mock Input System**: `MockInput` class provides controllable terminal input simulation
- **Test Utilities**: `TestFactory` provides standardized data creation for tests
- **Dependency Injection**: Tests use overloaded factory methods to inject mock dependencies

### Test Organization (`Tests/SwiftPickerTests/`)

- **Shared/** - Integration and shared behavior tests:
  - `SingleSelectionTests.swift`: Single item selection scenarios
  - `MultiSelectionTests.swift`: Multiple item selection scenarios
  - `EdgeCaseTests.swift`: Boundary conditions and special scenarios
  - `ConvenienceMethodTests.swift`: Helper methods and utilities
  - `BaseSelectionHandlerTests.swift`: Core selection handler logic
- **UnitTests/** - Test utilities and mocks:
  - `MockInput.swift`: Mock terminal input for testing
  - `TestFactory.swift`: Standardized test data factory

### Key Test Patterns
- **Behavior-Driven Descriptions**: Tests use descriptive names like "User can select multiple items using spacebar then confirm with Enter"
- **Dependency Injection**: `SelectionHandlerFactory.makeSingleSelectionHandler(info:newScreen:inputHandler:)` enables isolated testing
- **Test Data Factory**: `TestFactory.makePickerInfo(title:items:allowQuit:)` creates standardized test data
- **Mock Input Queuing**: Special characters (enter, space, quit) and direction keys simulated
- **Protocol Testing**: Validates conformance to `DisplayablePickerItem`, `PickerPrompt`, and composition protocols
- **Edge Case Coverage**: Empty lists, quit behavior, boundary navigation, Unicode support

### Test Execution
- **Concurrent Execution**: Tests run in parallel for performance (race conditions eliminated)
- **Isolated State**: No shared mutable state between tests

## Code Conventions

- **Module Organization**: Clear separation between public API (`API/`), core logic (`Engine/`), and I/O (`IO/`)
- **Access Control**:
  - Public APIs in `API/` module
  - Engine and IO modules use package-internal access by default (no explicit `internal` modifiers)
- **Protocol-Oriented Design**: Composition-based protocols (`CommandLineInput`, `CommandLinePermission`, `CommandLineSelection`, `DisplayablePickerItem`, `PickerPrompt`, `PickerInput`)
- **Generic Constraints**: Selection methods use `<Item: DisplayablePickerItem>` generic constraints
- **Error Handling**: Custom `SwiftPickerError` enum for picker-specific errors
- **Extension Organization**: Public API methods organized in separate extensions by functionality (Input, Permission, SingleSelection, MultiSelection)
- **Backward Compatibility**: Deprecated type aliases (`Picker` → `CommandLinePicker`, `SwiftPicker` → `InteractivePicker`) maintain API compatibility
- **Protocol Properties**: `DisplayablePickerItem.displayName`, `PickerPrompt.title` for consistent interface
- **Dependency Injection**: Overloaded factory methods support both default and custom input handlers
- **Factory Pattern**: `SelectionHandlerFactory` creates selection handlers with proper dependency injection

## Platform Requirements

- **macOS 10.14+** minimum deployment target
- **Swift 5.9+** toolchain requirement
- **Terminal environment** required for ANSI escape sequence support