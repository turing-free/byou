import Cocoa
import AppKit
import ApplicationServices

class AppDelegate: NSObject, NSApplicationDelegate {
    private var hotkeyManager: HotkeyManager?
    private let clipboardManager = ClipboardManager.shared
    private let mouseManager = MouseManager.shared

    private let translationManager = TencentTranslationManager()

    private var popover: NSPopover?
    private var popoverViewController: PopoverViewController?
    private var anchorWindow: NSWindow?
    private var anchorView: NSView?
    private var settingsWindow: NSWindow?
    private var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        DebugLog.debug("byou started. Press Alt+S to capture selected content, Alt+X for double-click.")

        checkAccessibilityPermissions()

        anchorView = NSView(frame: NSRect(x: 0, y: 0, width: 1, height: 1))
        anchorWindow = NSWindow(contentRect: anchorView!.frame, styleMask: [], backing: .buffered, defer: false)
        anchorWindow?.contentView = anchorView
        anchorWindow?.isReleasedWhenClosed = false
        anchorWindow?.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.overlayWindow)))
        anchorWindow?.orderFront(nil)
        anchorWindow?.setFrameOrigin(NSPoint(x: -1000, y: -1000))

        if ConfigManager.shared.isTencentConfigured {
            DebugLog.debug("Tencent Translation API configured")
        } else {
            DebugLog.debug("Tencent Translation API not configured. Configure credentials in settings.")
        }

        hotkeyManager = HotkeyManager()
        hotkeyManager?.onHotkeySPressed = { [weak self] in
            self?.handleHotkeyS()
        }

        hotkeyManager?.onHotkeyXPressed = { [weak self] in
            self?.handleHotkeyX()
        }

        setupMenuBar()

        NSApp.setActivationPolicy(.accessory)
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        guard let statusItem = statusItem else {
            DebugLog.error("Failed to create status item")
            return
        }

        DebugLog.debug("Status item created successfully")

        if let button = statusItem.button {
            DebugLog.debug("Status button available")
            if #available(macOS 11.0, *) {
                if let image = NSImage(systemSymbolName: "globe", accessibilityDescription: "Translation") {
                    button.image = image
                    DebugLog.debug("Using system globe icon")
                } else {
                    button.title = "🌐"
                    DebugLog.debug("Using emoji icon")
                }
            } else {
                button.title = "🌐"
                DebugLog.debug("Using emoji icon (macOS < 11)")
            }
        }

        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
        DebugLog.debug("Status bar menu configured")
    }

    @objc private func openSettings() {
        if settingsWindow != nil {
            settingsWindow?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let settingsVC = SettingsViewController()
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 360),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Settings"
        window.contentViewController = settingsVC
        window.center()
        window.isReleasedWhenClosed = false

        NSApp.setActivationPolicy(.regular)
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)

        settingsWindow = window

        DebugLog.debug("Settings window opened")
    }

    private func ensurePopoverInitialized() {
        if popover == nil {
            popover = NSPopover()
            popover?.contentViewController = PopoverViewController()
            popoverViewController = popover?.contentViewController as? PopoverViewController
            popover?.behavior = .transient
            popover?.animates = true

            // Pre-load the view to ensure layout is ready
            _ = popoverViewController?.view
        }
    }

    private func showPopover() {
        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)

            if self.popover == nil {
                self.popover = NSPopover()
                self.popover?.contentViewController = PopoverViewController()
                self.popoverViewController = self.popover?.contentViewController as? PopoverViewController
                self.popover?.behavior = .transient
                self.popover?.animates = true
            }

            self.popover?.contentSize = CGSize(width: 390, height: 400)

            let mouseLocation = NSEvent.mouseLocation
            let popoverSize = CGSize(width: 390, height: 400)

            var anchorOrigin = NSPoint(x: mouseLocation.x, y: mouseLocation.y)
            var preferredEdge: NSRectEdge = .maxY

            if let screen = NSScreen.main {
                let screenFrame = screen.visibleFrame

                let spaceAboveMouse = mouseLocation.y - screenFrame.minY
                let showAbove = spaceAboveMouse >= popoverSize.height

                if showAbove {
                    anchorOrigin.y = mouseLocation.y - 7
                    preferredEdge = .maxY
                } else {
                    anchorOrigin.y = mouseLocation.y + 7
                    preferredEdge = .minY
                }

                if anchorOrigin.x < screenFrame.minX {
                    anchorOrigin.x = screenFrame.minX + 10
                }

                if anchorOrigin.x + popoverSize.width > screenFrame.maxX {
                    anchorOrigin.x = screenFrame.maxX - popoverSize.width - 10
                }
            }

            self.anchorWindow?.setFrameOrigin(anchorOrigin)

            self.popover?.show(relativeTo: NSRect(x: 0, y: 0, width: popoverSize.width, height: 1),
                                of: self.anchorView!,
                                preferredEdge: preferredEdge)

            if let popoverWindow = self.popover?.contentViewController?.view.window {
                popoverWindow.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.overlayWindow)))
                popoverWindow.orderFrontRegardless()
            }
        }
    }

    private func handleHotkeyS() {
        Thread.sleep(forTimeInterval: 0.05)
        if clipboardManager.copySelectedContent() != nil {
            Thread.sleep(forTimeInterval: 0.1)
            if let clipboardContent = clipboardManager.getClipboardContent() {
                if clipboardContent.isEmpty {
                    return
                }

                DebugLog.debug("Selected content: \(clipboardContent)")

                ensurePopoverInitialized()
                popoverViewController?.setOriginalText(clipboardContent)
                popoverViewController?.setTranslatedText("翻译中...")
                showPopover()

                Task {
                    let translation = await performTranslation(clipboardContent)
                    DebugLog.debug(translation)

                    await MainActor.run {
                        popoverViewController?.setTranslatedText(translation)
                    }

                    clipboardManager.clearClipboard()
                }
            }
        }
    }

    private func handleHotkeyX() {
        mouseManager.doubleClick()
        DebugLog.debug("Double-click simulated")

        Thread.sleep(forTimeInterval: 0.1)

        if clipboardManager.copySelectedContent() != nil {
            Thread.sleep(forTimeInterval: 0.1)
            if let clipboardContent = clipboardManager.getClipboardContent() {
                if clipboardContent.isEmpty {
                    return
                }

                DebugLog.debug("Selected content: \(clipboardContent)")

                ensurePopoverInitialized()
                popoverViewController?.setOriginalText(clipboardContent)
                popoverViewController?.setTranslatedText("翻译中...")
                showPopover()

                Task {
                    let translation = await performTranslation(clipboardContent)
                    DebugLog.debug(translation)

                    await MainActor.run {
                        popoverViewController?.setTranslatedText(translation)
                    }

                    clipboardManager.clearClipboard()
                }
            }
        }
    }

    private func performTranslation(_ text: String) async -> String {
        guard ConfigManager.shared.isTencentConfigured else {
            return "Translation: Not configured. Set Tencent Cloud credentials in settings."
        }

        return await translationManager.translateAndFormat(text, sourceLang: "en", targetLang: "zh")
    }

    private func checkAccessibilityPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false] as CFDictionary
        let isTrusted = AXIsProcessTrustedWithOptions(options)

        if isTrusted {
            DebugLog.debug("Accessibility permissions granted")
        } else {
            DebugLog.debug("Accessibility permissions not granted")
            showPermissionAlert()
        }
    }

    private func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "需要辅助功能权限"
        alert.informativeText = "byou 需要辅助功能权限来监听全局快捷键和捕获选中的内容。\n\n请前往：系统设置 > 隐私与安全 > 辅助功能\n\n勾选 byou 以授予权限，然后重启应用。"
        alert.alertStyle = .warning

        if let appIcon = NSImage(named: "AppIcon") {
            alert.icon = appIcon
        }

        alert.addButton(withTitle: "打开系统设置")
        alert.addButton(withTitle: "稍后")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                NSWorkspace.shared.open(url)
            }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window == settingsWindow {
            settingsWindow = nil
            NSApp.setActivationPolicy(.accessory)
            DebugLog.debug("Settings window closed, restoring accessory mode")
        }
    }
}
