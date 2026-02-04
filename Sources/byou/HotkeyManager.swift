import Cocoa

class HotkeyManager {
    private var monitor: Any?
    private let configManager = ConfigManager.shared

    var onHotkeySPressed: (() -> Void)?
    var onHotkeyXPressed: (() -> Void)?

    init() {
        setupGlobalHotkey()
    }

    func reloadHotkeys() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
        }
        setupGlobalHotkey()
    }

    private func setupGlobalHotkey() {
        let captureKeyCode = configManager.captureHotkeyKeyCode
        let captureModifiers = NSEvent.ModifierFlags(rawValue: configManager.captureHotkeyModifiers)
        let doubleClickKeyCode = configManager.doubleClickHotkeyKeyCode
        let doubleClickModifiers = NSEvent.ModifierFlags(rawValue: configManager.doubleClickHotkeyModifiers)

        DebugLog.debug("Setting up hotkeys - Capture: keyCode=\(captureKeyCode), modifiers=\(captureModifiers.rawValue); DoubleClick: keyCode=\(doubleClickKeyCode), modifiers=\(doubleClickModifiers.rawValue)")

        monitor = NSEvent.addGlobalMonitorForEvents(matching: [.flagsChanged, .keyDown]) { [weak self] event in
            guard let self = self else { return }

            let flags = event.modifierFlags

            if event.type == .keyDown {
                let eventModifiers = flags.intersection(.deviceIndependentFlagsMask)

                if event.keyCode == captureKeyCode && eventModifiers == captureModifiers {
                    DebugLog.debug("Capture hotkey triggered")
                    self.handleHotkeyS()
                } else if event.keyCode == doubleClickKeyCode && eventModifiers == doubleClickModifiers {
                    DebugLog.debug("Double click hotkey triggered")
                    self.handleHotkeyX()
                }
            }
        }
    }

    private func handleHotkeyS() {
        onHotkeySPressed?()
    }

    private func handleHotkeyX() {
        onHotkeyXPressed?()
    }

    deinit {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
