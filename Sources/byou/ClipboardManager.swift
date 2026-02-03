import AppKit

class ClipboardManager {
    static let shared = ClipboardManager()
    private let pasteboard = NSPasteboard.general

    private init() {}

    func copySelectedContent() -> String? {
        let source = CGEventSource(stateID: .hidSystemState)
        let cmdCDown = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: true)
        let cmdCUp = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: false)

        cmdCDown?.flags = .maskCommand
        cmdCUp?.flags = .maskCommand

        cmdCDown?.post(tap: .cgAnnotatedSessionEventTap)
        cmdCUp?.post(tap: .cgAnnotatedSessionEventTap)

        Thread.sleep(forTimeInterval: 0.1)

        return pasteboard.string(forType: .string)
    }

    func getClipboardContent() -> String? {
        return pasteboard.string(forType: .string)
    }

    func clearClipboard() {
        pasteboard.clearContents()
    }

    func copyContentToClipboard(_ content: String) {
        pasteboard.clearContents()
        pasteboard.setString(content, forType: .string)
    }
}
