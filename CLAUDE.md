# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SwiftPicker is a Swift Package Manager library that provides interactive command-line picker functionality for Swift applications. It supports single and multiple item selection with terminal-based UI using ANSI escape sequences.

## Architecture

### Core Components

- **`CommandLinePicker` Protocol** (`Sources/SwiftPicker/PickerFeature/Picker.swift`): Unified interface combining input, permission, and selection capabilities through protocol composition
- **Protocol Architecture**:
  - `CommandLineInput` (`Sources/SwiftPicker/PickerFeature/CommandLineInput.swift`): Text input methods (`getInput`, `getRequiredInput`)
  - `CommandLinePermission` (`Sources/SwiftPicker/PickerFeature/CommandLinePermission.swift`): Yes/no permission methods (`getPermission`)
  - `CommandLineSelection` (`Sources/SwiftPicker/PickerFeature/CommandLineSelection.swift`): Single/multi selection methods (`selectSingleItem`, `selectMultipleItems`)
- **`InteractivePicker` Struct** (`Sources/SwiftPicker/PickerFeature/InteractivePicker.swift`): Concrete implementation of `CommandLinePicker` (renamed from `SwiftPicker`)
- **`DisplayablePickerItem` Protocol** (`Sources/SwiftPicker/PickerFeature/DisplayablePickerItem.swift`): Items that can be displayed in picker lists (requires `displayName: String`)
- **`PickerPrompt` Protocol** (`Sources/SwiftPicker/PickerFeature/PickerPrompt.swift`): Prompt messages (requires `title: String`, String conforms by default)
- **`SwiftPickerError` Enum** (`Sources/SwiftPicker/PickerFeature/SwiftPickerError.swift`): Custom errors (`selectionCancelled`, `inputRequired`)

### Internal Architecture

- **PickerComposer** (`Sources/SwiftPicker/Internal/Composer/PickerComposer.swift`): Factory class that creates selection handlers with dependency injection support
  - Default methods: Use static `inputHandler` property
  - Overloaded methods: Accept custom `inputHandler` parameter for testing
- **Selection Handlers** (`Sources/SwiftPicker/Internal/SelectionHandler/`): 
  - `BaseSelectionHandler`: Abstract base class for selection logic and terminal management
  - `SingleSelectionHandler`: Handles single item selection (returns item or nil on quit)
  - `MultiSelectionHandler`: Handles multiple item selection (returns empty array on quit)
- **Input System** (`Sources/SwiftPicker/Internal/Input/`):
  - `PickerInput` protocol: Terminal input abstraction (`readSpecialChar`, `readDirectionKey`, cursor control)
  - `PickerInputAdapter`: Real terminal implementation
  - `Direction` enum: `.up`, `.down` navigation
  - `SpecialChar` enum: `.enter`, `.space`, `.quit` actions
- **Models** (`Sources/SwiftPicker/Internal/Models/`): Core data structures including `Option`, `PickerInfo`, `SelectionState`

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
- **Comprehensive Coverage**: 52 tests across 6 test suites covering all major functionality
- **Mock Input System**: `MockInput` class provides controllable terminal input simulation
- **Dependency Injection**: Tests use overloaded composer methods to inject mock dependencies

### Test Suites
- **InteractivePickerTests.swift**: Public API testing (12 tests)
- **SwiftPickerErrorTests.swift**: Error handling and validation (12 tests)
- **EdgeCaseTests.swift**: Boundary conditions and special scenarios (20 tests)
- **ProtocolConformanceTests.swift**: Protocol implementation validation (15 tests)
- **ConvenienceMethodTests.swift**: Helper methods and utilities (8 tests)
- **BaseSelectionHandlerTests.swift**: Core selection logic (5 tests)
- **SwiftPickerIntegrationTests.swift**: End-to-end integration scenarios

### Key Test Patterns
- **Behavior-Driven Descriptions**: Tests use descriptive names like "User can select multiple items using spacebar then confirm with Enter"
- **Dependency Injection**: `PickerComposer.makeSingleSelectionHandler(info:newScreen:inputHandler:)` enables isolated testing
- **Mock Limitations**: Complex navigation scenarios simplified due to mock input system constraints
- **Protocol Testing**: Validates conformance to `DisplayablePickerItem`, `PickerPrompt`, and composition protocols
- **Edge Case Coverage**: Empty lists, quit behavior, boundary navigation, Unicode support

### Test Execution
- **Concurrent Execution**: Tests run in parallel for performance (race conditions eliminated)
- **Isolated State**: No shared mutable state between tests
- **Mock Input Queuing**: Special characters (enter, space, quit) and direction keys simulated

## Code Conventions

- **Access Control**: Public APIs in `PickerFeature/`, internal implementation in `Internal/`
- **Protocol-Oriented Design**: Composition-based protocols (`CommandLineInput`, `CommandLinePermission`, `CommandLineSelection`, `DisplayablePickerItem`, `PickerPrompt`, `PickerInput`)
- **Generic Constraints**: Selection methods use `<Item: DisplayablePickerItem>` generic constraints
- **Error Handling**: Custom `SwiftPickerError` enum for picker-specific errors
- **Extension Organization**: Public API methods organized in separate extensions by functionality (Input, Permission, SingleSelection, MultiSelection)
- **Backward Compatibility**: Deprecated type aliases (`Picker` → `CommandLinePicker`, `SwiftPicker` → `InteractivePicker`) maintain API compatibility
- **Protocol Properties**: `DisplayablePickerItem.displayName`, `PickerPrompt.title` for consistent interface
- **Dependency Injection**: Overloaded composer methods support both default and custom input handlers

## Platform Requirements

- **macOS 10.14+** minimum deployment target
- **Swift 5.0+** toolchain requirement
- **Terminal environment** required for ANSI escape sequence support