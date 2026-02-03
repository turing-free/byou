# Multi-Screen Mouse Double-Click Fix

## TL;DR

> **Quick Summary**: Fix mouse double-click positioning in multi-screen setup by using the correct screen coordinates instead of always assuming main screen height.
>
> **Deliverables**:
> - Modified `MouseManager.swift` with correct multi-screen coordinate calculation
>
> **Estimated Effort**: Short
> **Parallel Execution**: NO - sequential
> **Critical Path**: Identify current screen → Calculate correct coordinates → Test on both screens

---

## Context

### Original Request
用户报告：在主屏幕上 Alt+X 模拟鼠标双击能正常获取web页面单词，但把页面移动到另一个屏幕时，模拟双击鼠标点击到了上面一行单词的位置。用户外接了一个显示器（双屏设置）。

### Root Cause Analysis

**Current Code Problem** (MouseManager.swift:12-15):
```swift
guard let screenHeight = NSScreen.main?.frame.height else { return }
let mouseLocation = NSEvent.mouseLocation
let targetLocation = CGPoint(x: mouseLocation.x, y: screenHeight - mouseLocation.y)
```

**Why This Fails on Secondary Screens:**
1. Code always uses `NSScreen.main?.frame.height` (primary screen only)
2. `NSEvent.mouseLocation` returns global coordinates across all screens
3. Secondary screens have different `frame.minY` positions (could be negative or positive)
4. Y-coordinate calculation assumes main screen origin (0,0)

**Example Scenario:**
```
Main screen (primary): frame = (0, 0, 1920, 1080)
Secondary screen: frame = (1920, -300, 1920, 1080)

When mouse at (2500, 500) on secondary screen:
- Current code: targetLocation.y = 1080 - 500 = 580
- Correct: targetLocation.y = 500 - (-300) = 800
- Result: Clicks at wrong Y position!
```

---

## Work Objectives

### Core Objective
Fix mouse double-click positioning to work correctly across all connected displays.

### Concrete Deliverables
- Modified `MouseManager.swift` with proper multi-screen coordinate calculation

### Definition of Done
- [ ] Build succeeds with no errors
- [ ] Double-click works correctly on primary screen
- [ ] Double-click works correctly on secondary screen (at the correct word position)

### Must Have
- Find the screen where mouse is currently located
- Use that screen's `frame.minY` to calculate correct Y coordinate
- Maintain fallback to main screen if screen not found

### Must NOT Have (Guardrails)
- No hardcoded assumption about main screen
- No breaking changes to existing API
- No removal of existing double-click functionality

---

## Verification Strategy

### Test Decision
- **Infrastructure exists**: NO
- **User wants tests**: NO
- **QA approach**: Manual verification

### Manual Verification Procedure

**Test 1: Primary Screen**
1. Run app: `./run.sh`
2. Open a web page on primary screen
3. Select an English word (e.g., "Hello")
4. Press Alt+X
5. Verify: Popover appears with correct word "Hello"
6. Verify: Word is exactly where the cursor was (not above or below)

**Test 2: Secondary Screen**
1. Move web page to secondary monitor
2. Select an English word on secondary screen
3. Press Alt+X
4. Verify: Popover appears with correct word (not the line above)
5. Verify: Word is exactly where the cursor was on the secondary screen
6. Repeat with words at different positions (top, middle, bottom of screen)

**Test 3: Edge Cases**
1. Move mouse to edge between screens
2. Test Alt+X
3. Verify: No crashes, handles gracefully

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 1:
└── Task 1: Fix multi-screen coordinate calculation in MouseManager.swift

Wave 2 (After Wave 1):
└── Task 2: Build and verify the fix
```

---

## TODOs

- [ ] 1. Fix multi-screen coordinate calculation in MouseManager.swift

  **What to do**:
  - Modify `doubleClick()` method to find the screen containing the mouse cursor
  - Use the correct screen's `frame.minY` to calculate Y coordinate
  - Extract double-click event sending logic to a private method for better organization
  - Add fallback to main screen if screen detection fails

  **Must NOT do**:
  - Do not use hardcoded main screen height for all calculations
  - Do not assume secondary screens have same coordinate system as primary

  **Recommended Agent Profile**:
  > Select category + skills based on task domain. Justify each choice.
  - **Category**: `quick`
    - Reason: Single file modification with clear algorithmic fix
  - **Skills**: `[]`
    - No special skills needed - straightforward code change

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential
  - **Blocks**: Task 2
  - **Blocked By**: None (can start immediately)

  **References** (CRITICAL - Be Exhaustive):

  **Pattern References** (existing code to follow):
  - `Sources/but-you/MouseManager.swift:9-52` - Current double-click implementation (identify what to refactor)

  **API/Type References** (contracts to implement against):
  - `NSScreen.screens` - Array of all connected displays
  - `NSScreen.frame.contains(_:)` - Method to check if point is within screen bounds
  - `NSEvent.mouseLocation` - Global mouse coordinates (across all screens)
  - `CGEvent(mouseEventSource:mouseType:mouseCursorPosition:mouseButton:)` - Event creation API

  **External References** (libraries and frameworks):
  - Apple Docs: NSScreen class reference - Understanding multi-screen coordinate systems
  - Apple Docs: NSEvent.mouseLocation - Global coordinate system behavior

  **WHY Each Reference Matters** (explain the relevance):
  - `MouseManager.swift:9-52` - Understanding current implementation to refactor correctly
  - `NSScreen.screens` - Need to iterate through all screens to find the one containing mouse
  - `frame.contains(_:)` - Most reliable way to detect which screen the mouse is on
  - `frame.minY` - Critical for correct Y-coordinate calculation on secondary screens

  **Acceptance Criteria**:

  **Automated Verification (build check):**
  ```bash
  # Agent runs:
  cd "/Users/turing/opencode/but you" && swift build
  # Assert: Exit code 0 (success)
  # Assert: Build complete! message
  ```

  **Evidence to Capture:**
  - [ ] Build output showing "Build complete!"
  - [ ] No compilation errors

  **Commit**: YES
  - Message: `fix(mouse): Correct double-click coordinates for multi-screen displays`
  - Files: `Sources/but-you/MouseManager.swift`
  - Pre-commit: `swift build`

---

- [ ] 2. Manual verification and testing

  **Must NOT do**:
  - Do not skip testing on secondary screen
  - Do not assume it works without verification

  **Recommended Agent Profile**:
  > Select category + skills based on task domain. Justify each choice.
  - **Category**: `unspecified-low`
    - Reason: Manual testing task, no code changes
  - **Skills**: [`dev-browser`]
    - `dev-browser`: For navigating web pages and performing mouse interactions during testing

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential
  - **Blocks**: None (final task)
  - **Blocked By**: Task 1 (must fix first, then test)

  **References** (CRITICAL - Be Exhaustive):

  **Context References** (what was reported):
  - User issue: Alt+X clicks on wrong line on secondary screen (line above instead of current line)

  **Test References**:
  - Previous session notes: Alt+S and Alt+X hotkeys functionality
  - Current behavior: Works correctly on primary screen, incorrect on secondary

  **Acceptance Criteria**:

  **Manual Verification Steps:**
  ```bash
  # Agent executes interactive testing:
  1. Run: ./run.sh
  2. Open web browser
  3. On primary screen: Select word "Hello", press Alt+X
  4. Verify: Popover shows "Hello" (not word from line above)
  5. Move window to secondary screen
  6. On secondary screen: Select word "World", press Alt+X
  7. Verify: Popover shows "World" (NOT the word from line above)
  8. Test multiple positions on both screens
  9. Verify: Consistent correct behavior
  ```

  **Evidence to Capture**:
  - [ ] Terminal output showing app running
  - [ ] Screenshot evidence (optional) showing correct word selection on secondary screen

  **Commit**: NO
  - This is a testing task, no code changes

---

## Commit Strategy

| After Task | Message | Files | Verification |
|------------|---------|-------|--------------|
| 1 | `fix(mouse): Correct double-click coordinates for multi-screen displays` | MouseManager.swift | swift build |

---

## Success Criteria

### Verification Commands
```bash
swift build  # Expected: Build complete!
```

### Final Checklist
- [ ] All "Must Have" present
- [ ] All "Must NOT Have" absent
- [ ] Double-click works correctly on primary screen
- [ ] Double-click works correctly on secondary screen
- [ ] No coordinate offset issues on any screen
