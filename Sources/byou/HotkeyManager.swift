import Cocoa

class HotkeyManager {
    private var monitor: Any?

    var onHotkeySPressed: (() -> Void)?
    var onHotkeyXPressed: (() -> Void)?

    init() {
        setupGlobalHotkey()
    }

    private func setupGlobalHotkey() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: [.flagsChanged, .keyDown]) { [weak self] event in
            guard let self = self else { return }

            let flags = event.modifierFlags
            let isAltPressed = flags.contains(.option)

            if isAltPressed && event.type == .keyDown {
                if event.keyCode == 1 {
                    self.handleHotkeyS()
                } else if event.keyCode == 7 {
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
