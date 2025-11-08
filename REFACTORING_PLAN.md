# Text Truncation and Selected Item Display Refactoring Plan

## Overview
This plan encapsulates text truncation and selected item display logic to make these features reusable across all selection handlers (Single, Multi, and Column).

## Current State
- `ColumnSelectionHandler` has custom logic for:
  - Truncating text to fit within column width (`truncate(_:maxWidth:)`)
  - Centering text within a given width (`centerText(_:inWidth:)`)
  - Rendering selected item name at bottom of screen (`renderSelectedItemName(at:screenWidth:)`)
- `SingleSelectionHandler` and `MultiSelectionHandler` inherit from `BaseSelectionHandler` and lack these features
- **Architecture Note:** `ColumnSelectionHandler` is a standalone class that does NOT inherit from `BaseSelectionHandler`

## Goal State
- All selection handlers can:
  - Truncate item display names to fit within available space
  - Display the currently selected/highlighted item at the bottom of the screen
  - Center text within a given width
- Logic is maintained in shared utilities for consistency and maintainability

---

## Phase 1: Add Helper Methods to BaseSelectionHandler ✅ COMPLETED

**Objective:** Add `truncate` and `centerText` methods to `BaseSelectionHandler` for use by `SingleSelectionHandler` and `MultiSelectionHandler`.

**Completed Tasks:**
1. ✅ Read `BaseSelectionHandler.swift` to understand current structure
2. ✅ Add `truncate(_:maxWidth:)` method to `BaseSelectionHandler`
3. ✅ Verify `centerText(_:inWidth:)` already exists in `BaseSelectionHandler`
4. ✅ Verify methods are accessible to subclasses (internal access)

**Files Modified:**
- `Sources/SwiftPicker/Engine/Core/BaseSelectionHandler.swift`

**Testing:** ✅ All 114 tests passed - No behavior changes, existing functionality unchanged.

---

## Phase 2: Create Generic Selected Item Renderer ✅ COMPLETED

**Objective:** Add a generic method to `BaseSelectionHandler` for rendering selected items at the bottom of the screen.

**Completed Tasks:**
1. ✅ Add `renderSelectedItem<Item: DisplayablePickerItem>(_:at:screenWidth:)` method to `BaseSelectionHandler`
2. ✅ Method implementation:
   - Accepts any `DisplayablePickerItem`
   - Uses "Selected: " prefix
   - Truncates item name if needed (using `truncate` helper)
   - Centers the text (using `centerText` helper)
   - Applies cyan color styling (foreColor 51)
   - Renders at specified row position

**Files Modified:**
- `Sources/SwiftPicker/Engine/Core/BaseSelectionHandler.swift`

**Testing:** ✅ All 114 tests passed - Method added without breaking changes.

---

## Phase 3: Create Shared Text Formatting Utility (REVISED)

**Objective:** Create a shared utility enum with static methods for text formatting that can be used by both `BaseSelectionHandler` and `ColumnSelectionHandler`.

**Why This Change:** `ColumnSelectionHandler` doesn't inherit from `BaseSelectionHandler`, so we need a shared utility that both can use independently.

**Tasks:**
1. Create new file `Sources/SwiftPicker/Engine/Utilities/PickerTextFormatter.swift`
2. Create `PickerTextFormatter` enum with static methods:
   - `centerText(_:inWidth:)` - Centers text within specified width
   - `truncate(_:maxWidth:)` - Truncates text with ellipsis
3. Update `BaseSelectionHandler` to use `PickerTextFormatter` utilities
4. Update `ColumnSelectionHandler` to use `PickerTextFormatter` utilities
5. Ensure both classes delegate to shared utilities instead of local implementations

**Files to Create:**
- `Sources/SwiftPicker/Engine/Utilities/PickerTextFormatter.swift`

**Files to Modify:**
- `Sources/SwiftPicker/Engine/Core/BaseSelectionHandler.swift`
- `Sources/SwiftPicker/Engine/Core/ColumnSelectionHandler.swift`

**Testing:**
- Run all tests to verify no regression
- `swift test`

---

## Phase 4: Add Selected Item Renderer Helper to BaseSelectionHandler

**Objective:** Add a helper method in `BaseSelectionHandler` that uses `PickerInput` to render selected items.

**Tasks:**
1. Create `renderSelectedItemDisplay(_:at:screenWidth:)` method in `BaseSelectionHandler`
2. Method should accept an item and delegate formatting to `PickerTextFormatter`
3. Method uses `inputHandler` (PickerInput) to write to terminal
4. This provides a convenient wrapper for subclasses

**Files Modified:**
- `Sources/SwiftPicker/Engine/Core/BaseSelectionHandler.swift`

**Testing:**
- Verify build compiles
- `swift build`

---

## Phase 5: Update SingleSelectionHandler

**Objective:** Add selected item display and text truncation to single selection mode.

**Tasks:**
1. Read `SingleSelectionHandler.swift` to understand rendering structure
2. Update rendering to:
   - Truncate item display names using `PickerTextFormatter.truncate` (via inherited helper)
   - Reserve space at bottom for selected item display
   - Call inherited `renderSelectedItem` to display current selection at bottom
3. Adjust footer positioning to accommodate selected item row
4. Add horizontal separator line above footer (matching ColumnSelectionHandler pattern)

**Files Modified:**
- `Sources/SwiftPicker/Engine/Core/SingleSelectionHandler.swift`

**Testing:**
- Run single selection tests: `swift test --filter SingleSelectionTests`
- Manual testing to verify visual appearance

---

## Phase 6: Update MultiSelectionHandler

**Objective:** Add selected item display and text truncation to multi-selection mode.

**Tasks:**
1. Read `MultiSelectionHandler.swift` to understand rendering structure
2. Update rendering to:
   - Truncate item display names using `PickerTextFormatter.truncate` (via inherited helper)
   - Reserve space at bottom for highlighted item display
   - Call inherited `renderSelectedItem` to show currently highlighted item (not all selected items)
3. Adjust footer positioning to accommodate selected item row
4. Add horizontal separator line above footer (matching ColumnSelectionHandler pattern)

**Files Modified:**
- `Sources/SwiftPicker/Engine/Core/MultiSelectionHandler.swift`

**Testing:**
- Run multi-selection tests: `swift test --filter MultiSelectionTests`
- Manual testing to verify visual appearance

---

## Benefits

1. **DRY Principle:** Single source of truth for text formatting and selected item rendering
2. **Consistency:** All selection handlers display selected items identically with same formatting rules
3. **Maintainability:** Changes to text formatting/styling only need to happen in `PickerTextFormatter`
4. **Architecture:** Shared utility works for both inheritance-based and standalone selection handlers
5. **Testability:** Static utility methods are easy to unit test in isolation
6. **User Experience:** Consistent, polished UI across all selection modes (single, multi, column)

---

## Architecture Decision

**Why Shared Utility Instead of Inheritance:**
- `ColumnSelectionHandler` is a standalone class (doesn't inherit from `BaseSelectionHandler`)
- Both `BaseSelectionHandler` and `ColumnSelectionHandler` need the same text formatting logic
- Shared utility (`PickerTextFormatter`) provides reusable formatting without forcing inheritance
- Maintains flexibility in class design while promoting code reuse

---

## Risk Mitigation

- Each phase includes testing to catch regressions early
- Existing test suite validates behavior remains correct (114 tests)
- Changes are incremental and can be rolled back if needed
- Phase 1-2 already completed successfully without breaking changes
- Manual testing recommended for visual verification of new features
- Phases can be implemented and tested independently
