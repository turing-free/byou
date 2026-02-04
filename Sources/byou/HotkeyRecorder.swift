import Cocoa

class HotkeyRecorder: NSObject {
    private var monitor: Any?
    private var recordingTextField: NSTextField?
    private var onHotkeyRecorded: ((UInt32, UInt) -> Void)?

    override init() {
        super.init()
    }

    func startRecording(for textField: NSTextField, completion: @escaping (UInt32, UInt) -> Void) {
        stopRecording()

        recordingTextField = textField
        onHotkeyRecorded = completion

        textField.stringValue = "按下快捷键..."

        monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { [weak self] event in
            guard let self = self else { return event }

            if event.type == .keyDown {
                let keyCode = UInt32(event.keyCode)
                let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask).rawValue

                let modifierFlags = NSEvent.ModifierFlags(rawValue: modifiers)

                if modifierFlags.contains(.command) || modifierFlags.contains(.option) ||
                   modifierFlags.contains(.control) || modifierFlags.contains(.shift) {

                    self.stopRecording()
                    self.onHotkeyRecorded?(keyCode, modifiers)

                    return nil
                }
            }

            return event
        }

        DebugLog.debug("Started recording hotkey for text field")
    }

    func stopRecording() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
        recordingTextField = nil
        onHotkeyRecorded = nil
    }

    deinit {
        stopRecording()
    }
}
