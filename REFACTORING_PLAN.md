# Text Truncation and Selected Item Display Refactoring Plan

## Overview
This plan encapsulates text truncation and selected item display logic from `ColumnSelectionHandler` into `BaseSelectionHandler` to make these features reusable across all selection handlers (Single, Multi, and Column).

## Current State
- `ColumnSelectionHandler` has custom logic for:
  - Truncating text to fit within column width (`truncate(_:maxWidth:)`)
  - Centering text within a given width (`centerText(_:inWidth:)`)
  - Rendering selected item name at bottom of screen (`renderSelectedItemName(at:screenWidth:)`)
- `SingleSelectionHandler` and `MultiSelectionHandler` lack these features

## Goal State
- All selection handlers can:
  - Truncate item display names to fit within available space
  - Display the currently selected/highlighted item at the bottom of the screen
  - Center text within a given width
- Logic is maintained in one place (`BaseSelectionHandler`) for consistency and maintainability

---

## Phase 1: Move Helper Methods to BaseSelectionHandler

**Objective:** Extract `truncate` and `centerText` methods from `ColumnSelectionHandler` and move them to `BaseSelectionHandler` as protected helpers.

**Tasks:**
1. Read `BaseSelectionHandler.swift` to understand current structure
2. Add `truncate(_:maxWidth:)` method to `BaseSelectionHandler`
3. Add `centerText(_:inWidth:)` method to `BaseSelectionHandler`
4. Verify these methods are accessible to subclasses (no access control changes needed for `internal`)

**Files Modified:**
- `Sources/SwiftPicker/Engine/Core/BaseSelectionHandler.swift`

**Testing:** No behavior changes yet - existing functionality remains unchanged.

---

## Phase 2: Create Generic Selected Item Renderer

**Objective:** Add a generic method to `BaseSelectionHandler` for rendering selected items at the bottom of the screen.

**Tasks:**
1. Add `renderSelectedItem<Item: DisplayablePickerItem>(_:at:screenWidth:)` method to `BaseSelectionHandler`
2. Method should:
   - Accept any `DisplayablePickerItem`
   - Use "Selected: " prefix
   - Truncate item name if needed (using `truncate` helper)
   - Center the text (using `centerText` helper)
   - Apply cyan color styling (foreColor 51)
   - Render at specified row position

**Files Modified:**
- `Sources/SwiftPicker/Engine/Core/BaseSelectionHandler.swift`

**Testing:** Method can be unit tested independently or verified in Phase 3.

---

## Phase 3: Update ColumnSelectionHandler

**Objective:** Refactor `ColumnSelectionHandler` to use base class methods instead of local implementations.

**Tasks:**
1. Remove local `truncate(_:maxWidth:)` method - use inherited version
2. Remove local `centerText(_:inWidth:)` method - use inherited version
3. Update `renderSelectedItemName` to call base class `renderSelectedItem` method
4. Remove `renderSelectedItemName` if it becomes redundant, or simplify it to just call base method
5. Update all call sites to use base class methods

**Files Modified:**
- `Sources/SwiftPicker/Engine/Core/ColumnSelectionHandler.swift`

**Testing:**
- Run existing column selection tests to verify no regression
- `swift test --filter ColumnSelectionTests`

---

## Phase 4: Update SingleSelectionHandler

**Objective:** Add selected item display and text truncation to single selection mode.

**Tasks:**
1. Update `renderSelection` method to:
   - Truncate item display names to fit screen width
   - Reserve space at bottom for selected item display
   - Call `renderSelectedItem` to display current selection at bottom
2. Adjust footer positioning to accommodate selected item row
3. Add separator line above footer (matching ColumnSelectionHandler pattern)

**Files Modified:**
- `Sources/SwiftPicker/Engine/Core/SingleSelectionHandler.swift`

**Testing:**
- Run single selection tests: `swift test --filter SingleSelectionTests`
- Manual testing to verify visual appearance

---

## Phase 5: Update MultiSelectionHandler

**Objective:** Add selected item display and text truncation to multi-selection mode.

**Tasks:**
1. Update `renderSelection` method to:
   - Truncate item display names to fit screen width
   - Reserve space at bottom for highlighted item display
   - Call `renderSelectedItem` to show currently highlighted item (not all selected items)
2. Adjust footer positioning to accommodate selected item row
3. Add separator line above footer (matching ColumnSelectionHandler pattern)

**Files Modified:**
- `Sources/SwiftPicker/Engine/Core/MultiSelectionHandler.swift`

**Testing:**
- Run multi-selection tests: `swift test --filter MultiSelectionTests`
- Manual testing to verify visual appearance

---

## Benefits

1. **DRY Principle:** Single source of truth for truncation and selected item rendering
2. **Consistency:** All selection handlers display selected items identically
3. **Maintainability:** Changes to styling/formatting only need to happen in one place
4. **Inheritance:** Natural fit with existing `BaseSelectionHandler` architecture
5. **User Experience:** Consistent, polished UI across all selection modes

---

## Risk Mitigation

- Each phase includes testing to catch regressions early
- Existing test suite validates behavior remains correct
- Changes are incremental and can be rolled back if needed
- Manual testing recommended for visual verification
