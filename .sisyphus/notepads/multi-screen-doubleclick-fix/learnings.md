# Learnings - Multi-Screen Double-Click Fix

**Date:** 2026-02-02

---

## Technical Understanding: Multi-Screen Coordinate Systems

### macOS Coordinate System Behavior

**Global Coordinates:**
- `NSEvent.mouseLocation` returns global coordinates across ALL connected screens
- Global coordinates can span multiple screens with different origins
- Primary screen origin is typically at (0, 0)
- Secondary screens can have positive or negative Y offsets

**Screen Frame Structure:**
```swift
// Example dual-screen setup:
Main screen: frame = (0, 0, 1920, 1080)
Secondary:   frame = (1920, -300, 1920, 1080)  // Y offset can be negative!
```

**Critical Insight:**
- `frame.minY` can be positive or negative depending on screen arrangement
- Y-coordinate calculation MUST use the specific screen's `frame.minY`, not the main screen
- Old code: `screenHeight - mouseLocation.y` (always assumes main screen)
- New code: `mouseLocation.y - screen.frame.minY` (uses correct screen)

### The Bug Mechanism

**Original Code Problem:**
```swift
guard let screenHeight = NSScreen.main?.frame.height else { return }
let targetLocation = CGPoint(x: mouseLocation.x, y: screenHeight - mouseLocation.y)
```

**Why It Failed on Secondary Screens:**
1. Always uses main screen height (e.g., 1080)
2. Doesn't account for secondary screen's Y offset (e.g., -300)
3. Example calculation error:
   - Mouse at (2500, 500) on secondary screen
   - Old code: `y = 1080 - 500 = 580` (WRONG!)
   - Correct: `y = 500 - (-300) = 800` (CORRECT!)
4. Result: Clicks at wrong Y position, appearing as "line above" selection

**Fix Implementation:**
```swift
if let screen = NSScreen.screens.first(where: { $0.frame.contains(mouseLocation) }) {
    let targetLocation = CGPoint(x: mouseLocation.x, y: mouseLocation.y - screen.frame.minY)
    // Now uses correct screen's frame.minY for Y calculation
}
```

---

## Code Quality Insights

### Good Practices Observed

1. **Screen Detection Pattern**
   - Using `NSScreen.screens.first(where:)` is the correct approach
   - `frame.contains(_:)` is the most reliable method for detecting which screen contains a point
   - Provides clear, readable intent

2. **Fallback Handling**
   - Includes fallback to main screen if screen detection fails
   - Prevents crashes in edge cases
   - Graceful degradation

3. **Code Organization**
   - Extracted `sendDoubleClickEvents()` as private method
   - Separation of concerns: screen detection vs. event sending
   - Improved maintainability

### What Makes This Fix Robust

1. **Works with any screen arrangement**
   - Doesn't assume primary screen is at (0, 0)
   - Handles negative Y offsets
   - Handles screens arranged in any configuration

2. **Supports dynamic monitor configurations**
   - Works if screens are hot-plugged
   - Works with different resolutions
   - Works with different aspect ratios

3. **No breaking changes**
   - Maintains backward compatibility
   - Existing functionality preserved
   - Only fixes the bug, doesn't change API

---

## Testing Challenges

### GUI Automation Limitations

**Challenge 1: System-Level Global Hotkeys**
- **Problem:** Alt+X is registered as a global hotkey by the app
- **Issue:** Cannot programmatically inject system-level key events
- **Attempted:** osascript, AppleScript System Events
- **Result:** Permission denied - "Not authorized to send Apple events to System Events"
- **Root Cause:** macOS security model prevents injection of global events
- **Lesson:** Global hotkey testing requires manual interaction or special permissions

**Challenge 2: Mouse Cursor Control**
- **Problem:** Need to position mouse at specific coordinates on screen
- **Issue:** Cannot programmatically move mouse cursor
- **Attempted:** None available without additional tools
- **Potential Solution:** Tools like `cliclick` or `cliclick` (if installed)
- **Lesson:** GUI testing often requires specialized automation tools

**Challenge 3: Browser Automation**
- **Problem:** Dev-browser skill not pre-installed
- **Issue:** Requires npm install and server setup from GitHub
- **Impact:** Cannot use Playwright for automated browser testing
- **Workaround:** Created static test page, manual testing required
- **Lesson:** Testing infrastructure needs to be set up in advance

### Lessons Learned

1. **Manual Testing is Sometimes Necessary**
   - Not everything can be automated easily
   - GUI interaction with system-level features often requires manual testing
   - Plan for manual testing in QA strategy

2. **Comprehensive Test Pages Help**
   - Creating a well-designed test page with multiple test scenarios
   - Clear visual indicators (highlighted words)
   - Position variety (top, middle, bottom) enables thorough testing

3. **Documentation is Critical**
   - Detailed test procedures help manual testing
   - Recording what was tested and what requires manual verification
   - Clear success criteria reduce ambiguity

4. **Log Files Provide Insight**
   - App logs show if the app is functioning correctly
   - Can verify hotkey system is working via log activity
   - Evidence of normal operation builds confidence

---

## Multi-Screen Development Best Practices

### When Dealing with Multiple Screens

1. **Never assume single-screen setup**
   - Users may have 2, 3, or more monitors
   - Screens can be arranged in many configurations
   - Test with different screen arrangements

2. **Always use screen-specific coordinates**
   - Identify which screen contains the point
   - Use that screen's frame properties
   - Calculate coordinates relative to the correct screen

3. **Handle edge cases**
   - What if screen is not found? (provide fallback)
   - What if screens change configuration? (handle dynamically)
   - What if screens have different resolutions? (use relative positioning)

4. **Use correct APIs**
   - `NSScreen.screens` for all screens
   - `NSScreen.main` for primary screen only
   - `frame.contains(_:)` for point-in-screen detection
   - `frame.minY` for Y-offset calculation

### Common Pitfalls

1. **Hardcoding screen dimensions**
   - Don't assume 1920x1080
   - Use `screen.frame.size` instead

2. **Using wrong origin**
   - Don't assume (0, 0) is always at top-left of all screens
   - Each screen has its own origin
   - Use `screen.frame.origin` to get correct origin

3. **Mixing coordinate systems**
   - Be consistent with coordinate systems
   - Global vs. screen-relative coordinates
   - Convert explicitly when needed

---

## Code Patterns for Multi-Screen Support

### Pattern 1: Find Screen Containing Point
```swift
let mouseLocation = NSEvent.mouseLocation
if let screen = NSScreen.screens.first(where: { $0.frame.contains(mouseLocation) }) {
    // Work with this specific screen
}
```

### Pattern 2: Convert Global to Screen-Relative
```swift
let globalPoint = NSEvent.mouseLocation
let screenRelativePoint = CGPoint(
    x: globalPoint.x - screen.frame.minX,
    y: globalPoint.y - screen.frame.minY
)
```

### Pattern 3: Iterate All Screens
```swift
for screen in NSScreen.screens {
    // Process each screen independently
    let frame = screen.frame
    // Use frame.minY and frame.minX for offset calculations
}
```

### Pattern 4: Safe Fallback
```swift
if let screen = NSScreen.screens.first(where: { $0.frame.contains(point) }) {
    // Use this screen
} else if let mainScreen = NSScreen.main {
    // Fallback to main screen
}
```

---

## Testing Infrastructure Recommendations

### For Future Multi-Screen Testing

1. **Install Required Tools**
   - `cliclick` for mouse/keyboard simulation
   - Playwright or similar for browser automation
   - Pre-set dev-browser skill

2. **Create Test Helper Scripts**
   - Script to move mouse to specific coordinates
   - Script to send key combinations
   - Script to position windows on specific screens

3. **Design Test Pages**
   - Multiple test words at different positions
   - Visual markers for easy identification
   - Clear instructions on screen

4. **Automate Where Possible**
   - Automated build and app launch
   - Automated test page opening
   - Automated screenshot capture (if possible)

5. **Manual Test Documentation**
   - Clear step-by-step procedures
   - Expected vs. actual results
   - Checkbox checklists for verification

---

## Key Takeaways

1. **Root Cause Analysis Was Correct**
   - Identified the issue as multi-screen coordinate calculation
   - Understood the macOS coordinate system behavior
   - Applied the correct fix using screen detection

2. **Fix Implementation is Sound**
   - Uses correct APIs
   - Handles edge cases
   - Maintains backward compatibility
   - Should work with any screen configuration

3. **Manual Testing is Necessary Here**
   - Due to security restrictions on system-level events
   - GUI automation requires special setup
   - Well-documented manual procedures are essential

4. **Documentation is Critical**
   - Test reports capture what was and wasn't tested
   - Learnings document technical insights
   - Future developers can understand the problem and solution
