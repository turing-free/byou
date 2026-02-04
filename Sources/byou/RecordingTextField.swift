import Cocoa

class RecordingTextField: NSTextField {
    private var onHotkeyRecorded: ((UInt32, UInt) -> Void)?
    private var isRecording = false
    private var onClick: (() -> Void)?
    private var eventMonitor: Any?

    func setOnClick(_ callback: @escaping () -> Void) {
        onClick = callback
    }

    func startRecording(completion: @escaping (UInt32, UInt) -> Void) {
        isRecording = true
        onHotkeyRecorded = completion
        stringValue = "按下快捷键..."
        isEnabled = true

        DebugLog.debug("Starting hotkey recording...")

        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            guard let self = self, self.isRecording else { return event }

            DebugLog.debug("Monitor captured keyDown: keyCode=\(event.keyCode)")

            let keyCode = UInt32(event.keyCode)
            let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask).rawValue
            let modifierFlags = NSEvent.ModifierFlags(rawValue: modifiers)

            DebugLog.debug("Checking modifiers: \(modifierFlags)")

            if modifierFlags.contains(.command) || modifierFlags.contains(.option) ||
               modifierFlags.contains(.control) || modifierFlags.contains(.shift) {

                DebugLog.debug("Hotkey recorded: keyCode=\(keyCode), modifiers=\(modifiers)")

                self.isRecording = false
                self.onHotkeyRecorded?(keyCode, modifiers)
                self.onHotkeyRecorded = nil
                self.eventMonitor = nil

                return nil
            }

            DebugLog.debug("No modifiers, passing event through")
            return event
        }

        if let window = window {
            let success = window.makeFirstResponder(self)
            DebugLog.debug("makeFirstResponder called: \(success)")
        } else {
            DebugLog.debug("No window available")
        }
    }

    func stopRecording() {
        isRecording = false
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
        onHotkeyRecorded = nil
    }

    override var acceptsFirstResponder: Bool {
        return true
    }

    override var canBecomeKeyView: Bool {
        return true
    }

    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        DebugLog.debug("becomeFirstResponder result: \(result)")
        return result
    }

    override func mouseDown(with event: NSEvent) {
        DebugLog.debug("mouseDown called")
        onClick?()
    }

    deinit {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
