# Column Selection Implementation Plan

## Overview

This document outlines the phased implementation of generic column selection behavior for SwiftPicker. The implementation maintains architectural integrity by following existing patterns and separation of concerns.

---

## Phase 1: Foundation Layer

**Goal**: Extend input abstractions to support horizontal navigation

### 1.1 Extend Direction Enum
**File**: `Sources/SwiftPicker/IO/PickerInput.swift`

**Changes**:
- Add `.left` and `.right` cases to `Direction` enum
- Update documentation

**Before**:
```swift
internal enum Direction {
    case up, down
}
```

**After**:
```swift
internal enum Direction {
    case up, down, left, right
}
```

### 1.2 Update PickerInputAdapter
**File**: `Sources/SwiftPicker/IO/PickerInputAdapter.swift`

**Changes**:
- Extend `readDirectionKey()` to handle left/right arrow keys
- Map ANSITerminal key codes to new Direction cases

**Implementation**:
```swift
func readDirectionKey() -> Direction? {
    let key = ANSITerminal.readKey()

    switch key.code {
    case .up: return .up
    case .down: return .down
    case .left: return .left
    case .right: return .right
    default: return nil
    }
}
```

### 1.3 Update Mock Input for Testing
**File**: `Tests/SwiftPickerTests/UnitTests/MockInput.swift`

**Changes**:
- Support queueing left/right directions
- Update `readDirectionKey()` to handle horizontal navigation in tests

**Deliverables**:
- ✅ Direction enum supports 4 directions
- ✅ PickerInputAdapter implements left/right navigation
- ✅ MockInput supports testing horizontal navigation
- ✅ All existing tests still pass

---

## Phase 2: Core Models & State Management

**Goal**: Create data models and state management for column selection

### 2.1 Create PickerColumn Model
**File**: `Sources/SwiftPicker/Engine/Models/PickerColumn.swift`

**Purpose**: Generic representation of a selectable column

**Implementation**:
```swift
/// Represents a single column in a multi-column picker
struct PickerColumn<Item: DisplayablePickerItem> {
    let title: String
    let items: [Item]
    var activeIndex: Int

    init(title: String, items: [Item], activeIndex: Int = 0) {
        self.title = title
        self.items = items
        self.activeIndex = activeIndex
    }

    var activeItem: Item? {
        guard activeIndex >= 0, activeIndex < items.count else { return nil }
        return items[activeIndex]
    }
}
```

### 2.2 Create ColumnSelectionState
**File**: `Sources/SwiftPicker/Engine/Models/ColumnSelectionState.swift`

**Purpose**: Manage multi-column selection state

**Implementation**:
```swift
/// Manages state for multi-column selection
final class ColumnSelectionState<Item: DisplayablePickerItem> {
    var columns: [PickerColumn<Item>]
    var activeColumnIndex: Int
    let title: String
    let topLine: Int

    init(
        columns: [PickerColumn<Item>],
        activeColumnIndex: Int = 0,
        title: String,
        topLine: Int
    ) {
        self.columns = columns
        self.activeColumnIndex = max(0, min(activeColumnIndex, columns.count - 1))
        self.title = title
        self.topLine = topLine
    }

    var activeColumn: PickerColumn<Item> {
        get { columns[activeColumnIndex] }
        set { columns[activeColumnIndex] = newValue }
    }

    var topLineText: String {
        "Use ←→ to switch columns, ↑↓ to navigate"
    }

    var bottomLineText: String {
        "Press Enter to select • Q to quit"
    }
}
```

**Deliverables**:
- ✅ PickerColumn model created
- ✅ ColumnSelectionState manages column state
- ✅ Models follow existing patterns (Option, SelectionState)

---

## Phase 3: Selection Handler Implementation

**Goal**: Implement column selection logic and rendering

### 3.1 Create ColumnSelectionHandler
**File**: `Sources/SwiftPicker/Engine/Core/ColumnSelectionHandler.swift`

**Purpose**: Handle column navigation, rendering, and user input

**Key Features**:
- Vertical navigation within columns (up/down)
- Horizontal navigation between columns (left/right)
- Enter to select active item
- Q to quit (returns nil)
- Dynamic column rendering based on screen width
- Visual indicators for active column and active item

**Structure**:
```swift
final class ColumnSelectionHandler<Item: DisplayablePickerItem> {
    private let state: ColumnSelectionState<Item>
    private let inputHandler: PickerInput
    private let columnWidth: Int
    private let columnSpacing: Int

    // MARK: - Public Interface
    func captureUserInput() -> Item?

    // MARK: - Private Navigation
    private func handleNavigation()
    private func moveVertical(delta: Int)
    private func moveHorizontal(delta: Int)

    // MARK: - Private Rendering
    private func renderColumns()
    private func renderColumn(_ column: PickerColumn<Item>, at xPosition: Int, isActive: Bool)
    private func endSelection()
}
```

**Rendering Design**:
- Active column + active item: `> ` (green) + item name
- Active column + inactive item: `  ` + item name (dim)
- Inactive column + active item: `• ` (yellow) + item name (dim)
- Inactive column + inactive item: `  ` + item name (dim)
- Column titles: underlined if active, dim if inactive
- Navigation hints at bottom

**Deliverables**:
- ✅ ColumnSelectionHandler implements full logic
- ✅ Follows BaseSelectionHandler patterns
- ✅ Handles all navigation cases
- ✅ Prevents out-of-bounds navigation
- ✅ Returns proper values (Item? on enter, nil on quit)

---

## Phase 4: Factory Integration

**Goal**: Add factory methods for creating column handlers

### 4.1 Extend SelectionHandlerFactory
**File**: `Sources/SwiftPicker/Engine/Factory/SelectionHandlerFactory.swift`

**Changes**:
- Add column selection factory methods
- Support both default and custom input handlers
- Follow existing dependency injection patterns

**Implementation**:
```swift
// MARK: - Column Selection
extension SelectionHandlerFactory {
    /// Creates a column selection handler with default input handler
    static func makeColumnSelectionHandler<Item: DisplayablePickerItem>(
        columns: [PickerColumn<Item>],
        title: String,
        newScreen: Bool
    ) -> ColumnSelectionHandler<Item>

    /// Creates a column selection handler with custom input handler (for testing)
    static func makeColumnSelectionHandler<Item: DisplayablePickerItem>(
        columns: [PickerColumn<Item>],
        title: String,
        newScreen: Bool,
        inputHandler: PickerInput
    ) -> ColumnSelectionHandler<Item>
}
```

**Deliverables**:
- ✅ Factory methods follow existing patterns
- ✅ Overloaded methods for default and testable variants
- ✅ Proper screen configuration
- ✅ Correct initial state setup

---

## Phase 5: Public API Integration

**Goal**: Expose column selection through public API

### 5.1 Add ColumnSelection to InteractivePicker
**File**: `Sources/SwiftPicker/API/Picker/InteractivePicker.swift`

**Changes**:
- Add public column selection method
- Follow existing API conventions
- Use PickerPrompt protocol for title

**Implementation**:
```swift
// MARK: - Column Selection
public extension InteractivePicker {
    /// Displays multiple columns for navigation and selection
    /// - Parameters:
    ///   - columns: Array of columns to display
    ///   - title: Title to display above columns
    ///   - newScreen: Whether to use alternative screen mode
    /// - Returns: Selected item from active column, or nil if user quits
    func columnSelection<Item: DisplayablePickerItem>(
        columns: [PickerColumn<Item>],
        title: some PickerPrompt = "",
        newScreen: Bool = true
    ) -> Item?
}
```

### 5.2 Make PickerColumn Public
**File**: Move to `Sources/SwiftPicker/API/Models/PickerColumn.swift`

**Changes**:
- Move PickerColumn to API module
- Make all members public
- Add comprehensive documentation

**Deliverables**:
- ✅ Public API follows existing conventions
- ✅ PickerColumn accessible to library users
- ✅ Method signature consistent with singleSelection/multiSelection
- ✅ Proper documentation

---

## Phase 6: Testing

**Goal**: Comprehensive test coverage for column selection

### 6.1 Update MockInput
**File**: `Tests/SwiftPickerTests/UnitTests/MockInput.swift`

**Changes**:
- Add left/right direction queuing
- Support horizontal navigation in tests

### 6.2 Create ColumnSelectionTests
**File**: `Tests/SwiftPickerTests/Shared/ColumnSelectionTests.swift`

**Test Coverage**:
1. **Navigation Tests**:
   - Navigates between columns using left/right arrows
   - Navigates vertically within active column
   - Preserves item position when switching columns

2. **Selection Tests**:
   - Returns selected item when Enter pressed
   - Returns nil when user quits
   - Returns correct item from active column

3. **Boundary Tests**:
   - Prevents navigation beyond column boundaries
   - Prevents vertical navigation beyond item boundaries
   - Handles empty columns gracefully
   - Handles single column mode

4. **Rendering Tests**:
   - Calculates correct column positions
   - Renders active/inactive states correctly
   - Handles screen width constraints

5. **Integration Tests**:
   - Test through InteractivePicker API
   - Verify dependency injection works
   - Test with custom PickerInput implementations

**Test Structure**:
```swift
@MainActor
struct ColumnSelectionTests {
    @Test("Description")
    func testMethodName() { }

    // MARK: - SUT
    private func makeSUT(...) -> (handler: ColumnSelectionHandler<String>, mock: MockInput)
    private static func makeTestItems(count: Int = 5) -> [String]
}
```

**Deliverables**:
- ✅ 15+ tests covering all scenarios
- ✅ Tests follow behavior-driven naming
- ✅ Uses makeSUT pattern with memory leak tracking
- ✅ All tests pass
- ✅ No regressions in existing tests

---

## Phase 7: Documentation & Examples

**Goal**: Update documentation and provide usage examples

### 7.1 Update README
**File**: `README.md`

**Additions**:
- Add column selection to features list
- Add column selection example
- Update API documentation

### 7.2 Update Module Documentation
**File**: `CLAUDE.md`

**Changes**:
- Document column selection architecture
- Add to API module section
- Add to Engine module section
- Update testing architecture section

### 7.3 Create Example Usage
**Example Code**:
```swift
import SwiftPicker

let folders = ["Documents", "Downloads", "Pictures"]
let files = ["file1.txt", "file2.txt", "file3.txt"]

let columns = [
    PickerColumn(title: "Folders", items: folders),
    PickerColumn(title: "Files", items: files)
]

let picker = InteractivePicker()
if let selected = picker.columnSelection(columns: columns, title: "Browse Files") {
    print("Selected: \(selected)")
}
```

**Deliverables**:
- ✅ README updated with examples
- ✅ CLAUDE.md documents new architecture
- ✅ Code examples are clear and functional

---

## Implementation Timeline

| Phase | Estimated Effort | Dependencies |
|-------|-----------------|--------------|
| Phase 1: Foundation | 30 mins | None |
| Phase 2: Models | 20 mins | Phase 1 |
| Phase 3: Handler | 1 hour | Phase 2 |
| Phase 4: Factory | 20 mins | Phase 3 |
| Phase 5: API | 15 mins | Phase 4 |
| Phase 6: Testing | 1 hour | Phases 1-5 |
| Phase 7: Docs | 30 mins | All phases |
| **Total** | **~4 hours** | - |

---

## Success Criteria

✅ All existing tests pass
✅ New tests provide comprehensive coverage
✅ No architectural violations
✅ Follows established patterns consistently
✅ Public API is intuitive and well-documented
✅ Memory leak tracking for all new components
✅ No direct ANSITerminal usage outside adapters
✅ Full dependency injection support for testing

---

## Future Enhancements (Out of Scope)

- Multi-selection within columns
- Dynamic column content updates
- Column resizing based on content
- Keyboard shortcuts (numbers, letters)
- Custom column renderers
- Nested column hierarchies

---

## Notes

- This implementation maintains backward compatibility
- No breaking changes to existing APIs
- All new code follows Swift Testing framework conventions
- Column selection is foundation for future SwiftFolderBrowser library
