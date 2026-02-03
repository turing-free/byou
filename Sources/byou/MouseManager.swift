import AppKit
import CoreGraphics

class MouseManager {
    static let shared = MouseManager()

    private init() {}

    func doubleClick() {
        guard let source = CGEventSource(stateID: .hidSystemState) else { return }
        let mouseLocation = NSEvent.mouseLocation

        if let screen = NSScreen.screens.first(where: { $0.frame.contains(mouseLocation) }) {
            // Flip Y coordinate: Quartz coordinate system (Y=0 at bottom)
            let targetLocation = CGPoint(
                x: mouseLocation.x,
                y: screen.frame.maxY - mouseLocation.y
            )
            sendDoubleClickEvents(at: targetLocation, source: source)
        }
    }

    private func sendDoubleClickEvents(at targetLocation: CGPoint, source: CGEventSource) {
        let moveToTarget = CGEvent(mouseEventSource: source, mouseType: .mouseMoved, mouseCursorPosition: targetLocation, mouseButton: .left)
        moveToTarget?.post(tap: CGEventTapLocation.cghidEventTap)
        Thread.sleep(forTimeInterval: 0.005)

        let mouseDown1 = CGEvent(mouseEventSource: source, mouseType: .leftMouseDown, mouseCursorPosition: targetLocation, mouseButton: .left)
        let mouseUp1 = CGEvent(mouseEventSource: source, mouseType: .leftMouseUp, mouseCursorPosition: targetLocation, mouseButton: .left)

        mouseDown1?.setIntegerValueField(CGEventField.mouseEventClickState, value: 1)
        mouseUp1?.setIntegerValueField(CGEventField.mouseEventClickState, value: 1)

        mouseDown1?.flags = .maskNonCoalesced
        mouseUp1?.flags = .maskNonCoalesced

        mouseDown1?.post(tap: CGEventTapLocation.cghidEventTap)
        Thread.sleep(forTimeInterval: 0.01)
        mouseUp1?.post(tap: CGEventTapLocation.cghidEventTap)

        Thread.sleep(forTimeInterval: 0.03)

        let moveToTarget2 = CGEvent(mouseEventSource: source, mouseType: .mouseMoved, mouseCursorPosition: targetLocation, mouseButton: .left)
        moveToTarget2?.post(tap: CGEventTapLocation.cghidEventTap)
        Thread.sleep(forTimeInterval: 0.005)

        let mouseDown2 = CGEvent(mouseEventSource: source, mouseType: .leftMouseDown, mouseCursorPosition: targetLocation, mouseButton: .left)
        let mouseUp2 = CGEvent(mouseEventSource: source, mouseType: .leftMouseUp, mouseCursorPosition: targetLocation, mouseButton: .left)

        mouseDown2?.setIntegerValueField(CGEventField.mouseEventClickState, value: 2)
        mouseUp2?.setIntegerValueField(CGEventField.mouseEventClickState, value: 2)

        mouseDown2?.flags = .maskNonCoalesced
        mouseUp2?.flags = .maskNonCoalesced

        mouseDown2?.post(tap: CGEventTapLocation.cghidEventTap)
        Thread.sleep(forTimeInterval: 0.01)
        mouseUp2?.post(tap: CGEventTapLocation.cghidEventTap)
    }
}
