# Changelog

All notable changes to SwiftPicker will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2025-10-24

### Added
- SwiftPickerTesting library with `MockSwiftPicker` class for unit testing command-line interactions
- Mock implementations supporting ordered responses (FIFO queue) and dictionary-based responses (keyed by prompt title)
- `MockInputResult`, `MockPermissionResult`, and `MockSelectionResult` structs for configurable mock behavior
- Comprehensive test suite with 39 tests for `MockSwiftPicker` functionality
- GitHub Actions CI workflow for automated PR builds and tests
- `TextInputHandler` protocol for dependency injection of text input handling
- `DefaultInputHandler` implementation for production text input
- Internal initializer for `InteractivePicker` enabling dependency injection in tests
- Test utilities including `MockTextInputHandler` and `TestFactory` for standardized test data
- Inline API documentation for `InteractivePicker` properties and initializer
- CI build status badge to README
- Table of contents to README

### Changed
- Reorganized source files into modular structure with API, Engine, and IO directories
- Renamed `PickerComposer` to `SelectionHandlerFactory` for clarity
- Reorganized test files by moving mocks to Shared directory and tests to UnitTests directory
- Split single and multi selection tests into separate files for better organization
- Refactored test methods to use behavior-driven naming conventions
- Updated Swift tools version requirement to 5.9+
- Improved README architecture section to reflect new module organization
- Enhanced CLAUDE.md with comprehensive SwiftPickerTesting documentation

### Fixed
- Removed unused internal access modifiers from Engine and IO modules for cleaner code

## [1.0.0] - 2025-08-10

### Added
- Protocol-oriented architecture with `CommandLinePicker` protocol that composes `CommandLineInput`, `CommandLinePermission`, and `CommandLineSelection`
- New `CommandLineInput` protocol for text input methods (`getInput`, `getRequiredInput`)
- New `CommandLinePermission` protocol for yes/no permission methods (`getPermission`)
- New `CommandLineSelection` protocol for single/multi selection methods (`selectSingleItem`, `selectMultipleItems`)
- `PickerPrompt` protocol for customizable prompt messages
- Comprehensive test coverage with 52+ tests across 6 test suites using Swift Testing framework
- Edge case tests for boundary conditions and special scenarios
- Protocol conformance tests for validation
- Convenience method tests for helper utilities
- Integration tests for end-to-end scenarios
- CLAUDE.md documentation file for AI-assisted development guidance

### Changed
- Renamed `SwiftPicker` struct to `InteractivePicker` for clarity (backward-compatible type alias maintained)
- Renamed `Picker` protocol to `CommandLinePicker` (backward-compatible type alias maintained)
- Enhanced README with comprehensive documentation, usage examples, and demo GIFs
- Improved `PickerComposer` with dependency injection support for better testability
- Updated test suite to use Swift Testing framework with behavior-driven test descriptions
- Reorganized protocol files - each protocol now in its own file for better maintainability

### Fixed
- Minor formatting and code organization improvements in `PickerComposer`
- Updated selection handlers to improve display consistency

## [0.8.0] - 2024-05-18

### Added
- Initial release with interactive command-line picker functionality
- Single item selection with arrow key navigation
- Multiple item selection with spacebar toggle and enter to confirm
- Text input methods (`getInput`, `getRequiredInput`)
- Yes/no permission prompts (`getPermission`)
- `DisplayablePickerItem` protocol for customizable picker items
- Terminal-based UI with ANSI escape sequences via ANSITerminal dependency
- Visual indicators for scrolling availability with arrows
- Quit functionality with 'q' key
- Comprehensive documentation in README with demo GIFs and examples
- Unit tests for base selection handler logic
- Integration tests for end-to-end scenarios
- Code documentation for all public APIs

### Security
- Proper terminal state management to ensure cursor visibility is restored after operations
