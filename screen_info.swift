import AppKit

print("Screen Information:")
print("=================")

for (index, screen) in NSScreen.screens.enumerated() {
    let frame = screen.frame
    print("\nScreen \(index):")
    print("  Frame: \(frame)")
    print("  Origin: (\(frame.origin.x), \(frame.origin.y))")
    print("  Size: \(frame.size.width) x \(frame.size.height)")
    print("  MinX: \(frame.minX), MinY: \(frame.minY)")
    print("  MaxX: \(frame.maxX), MaxY: \(frame.maxY)")
}

print("\nMain Screen:")
if let mainScreen = NSScreen.main {
    let frame = mainScreen.frame
    print("  Frame: \(frame)")
    print("  MinY: \(frame.minY)")
}
