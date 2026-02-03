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
        print("byou started. Press Alt+S to capture selected content, Alt+X for double-click.")

        // Check accessibility permissions
        checkAccessibilityPermissions()

        anchorView = NSView(frame: NSRect(x: 0, y: 0, width: 1, height: 1))
        anchorWindow = NSWindow(contentRect: anchorView!.frame, styleMask: [], backing: .buffered, defer: false)
        anchorWindow?.contentView = anchorView
        anchorWindow?.isReleasedWhenClosed = false
        anchorWindow?.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.overlayWindow)))
        anchorWindow?.orderFront(nil)
        anchorWindow?.setFrameOrigin(NSPoint(x: -1000, y: -1000))

        if ConfigManager.shared.isTencentConfigured {
            print("Tencent Translation API configured")
        } else {
            print("Tencent Translation API not configured. Configure credentials in settings.")
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
            print("ERROR: Failed to create status item")
            return
        }

        print("Status item created successfully")

        if let button = statusItem.button {
            print("Status button available")
            if #available(macOS 11.0, *) {
                if let image = NSImage(systemSymbolName: "globe", accessibilityDescription: "Translation") {
                    button.image = image
                    print("Using system globe icon")
                } else {
                    button.title = "🌐"
                    print("Using emoji icon")
                }
            } else {
                button.title = "🌐"
                print("Using emoji icon (macOS < 11)")
            }
        }

        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
        print("Status bar menu configured")
    }

    @objc private func openSettings() {
        if settingsWindow != nil {
            settingsWindow?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let settingsVC = SettingsViewController()
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Translation Settings"
        window.contentViewController = settingsVC
        window.center()
        window.isReleasedWhenClosed = false

        NSApp.setActivationPolicy(.regular)
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)

        settingsWindow = window

        print("Settings window opened")
    }

    private func showPopover(with content: String) {
        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)

            if self.popover == nil {
                self.popover = NSPopover()
                self.popover?.contentViewController = PopoverViewController()
                self.popoverViewController = self.popover?.contentViewController as? PopoverViewController
                self.popover?.behavior = .transient
                self.popover?.appearance = NSAppearance(named: .vibrantDark)
                self.popover?.animates = true
            }

            self.popoverViewController?.setContent(content)

            let mouseLocation = NSEvent.mouseLocation
            let popoverSize = CGSize(width: 400, height: 300)

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

                print("Selected content: \(clipboardContent)")

                Task {
                    let translation = await performTranslation(clipboardContent)
                    print(translation)

                    let displayContent = "\(clipboardContent)\n\n---\n\n\(translation)"
                    showPopover(with: displayContent)

                    clipboardManager.clearClipboard()
                }
            }
        }
    }

    private func handleHotkeyX() {
        mouseManager.doubleClick()
        print("Double-click simulated")

        Thread.sleep(forTimeInterval: 0.1)

        if clipboardManager.copySelectedContent() != nil {
            Thread.sleep(forTimeInterval: 0.1)
            if let clipboardContent = clipboardManager.getClipboardContent() {
                if clipboardContent.isEmpty {
                    return
                }

                print("Selected content: \(clipboardContent)")

                Task {
                    let translation = await performTranslation(clipboardContent)
                    print(translation)

                    let displayContent = "\(clipboardContent)\n\n---\n\n\(translation)"
                    showPopover(with: displayContent)

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
            print("Accessibility permissions granted")
        } else {
            print("Accessibility permissions not granted")
            showPermissionAlert()
        }
    }

    private func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "需要辅助功能权限"
        alert.informativeText = "byou 需要辅助功能权限来监听全局快捷键和捕获选中的内容。\n\n请前往：系统设置 > 隐私与安全 > 辅助功能\n\n勾选 byou 以授予权限，然后重启应用。"
        alert.alertStyle = .warning
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
            print("Settings window closed, restoring accessory mode")
        }
    }
}
