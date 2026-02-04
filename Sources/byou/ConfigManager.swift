import Foundation
import AppKit

/// 配置管理器 - 安全存储应用配置和凭证
class ConfigManager {
    static let shared = ConfigManager()

    private let userDefaults = UserDefaults.standard

    private init() {
        initializeDefaultHotkeys()
    }

    private func initializeDefaultHotkeys() {
        if !userDefaults.bool(forKey: "hotkey.defaults.set") {
            resetHotkeys()
            userDefaults.set(true, forKey: "hotkey.defaults.set")
        }
    }

    // MARK: - Tencent Cloud Configuration

    private enum Keys {
        static let tencentSecretId = "tencent.secretId"
        static let tencentSecretKey = "tencent.secretKey"
        static let tencentRegion = "tencent.region"
        static let captureHotkeyKeyCode = "hotkey.capture.keyCode"
        static let captureHotkeyModifiers = "hotkey.capture.modifiers"
        static let doubleClickHotkeyKeyCode = "hotkey.doubleClick.keyCode"
        static let doubleClickHotkeyModifiers = "hotkey.doubleClick.modifiers"
    }

    // MARK: - Tencent Cloud Credentials

    var tencentSecretId: String {
        get {
            return userDefaults.string(forKey: Keys.tencentSecretId) ?? ""
        }
        set {
            userDefaults.set(newValue, forKey: Keys.tencentSecretId)
        }
    }

    var tencentSecretKey: String {
        get {
            return userDefaults.string(forKey: Keys.tencentSecretKey) ?? ""
        }
        set {
            userDefaults.set(newValue, forKey: Keys.tencentSecretKey)
        }
    }

    var tencentRegion: String {
        get {
            return userDefaults.string(forKey: Keys.tencentRegion) ?? "ap-chengdu"
        }
        set {
            userDefaults.set(newValue, forKey: Keys.tencentRegion)
        }
    }

    var isTencentConfigured: Bool {
        return !tencentSecretId.isEmpty && !tencentSecretKey.isEmpty
    }

    // MARK: - Hotkey Configuration

    // 捕获快捷键（默认 Alt+S）
    var captureHotkeyKeyCode: UInt32 {
        get {
            return UInt32(userDefaults.integer(forKey: Keys.captureHotkeyKeyCode))
        }
        set {
            userDefaults.set(newValue, forKey: Keys.captureHotkeyKeyCode)
        }
    }

    var captureHotkeyModifiers: UInt {
        get {
            return UInt(userDefaults.integer(forKey: Keys.captureHotkeyModifiers))
        }
        set {
            userDefaults.set(newValue, forKey: Keys.captureHotkeyModifiers)
        }
    }

    // 双击快捷键（默认 Alt+X）
    var doubleClickHotkeyKeyCode: UInt32 {
        get {
            return UInt32(userDefaults.integer(forKey: Keys.doubleClickHotkeyKeyCode))
        }
        set {
            userDefaults.set(newValue, forKey: Keys.doubleClickHotkeyKeyCode)
        }
    }

    var doubleClickHotkeyModifiers: UInt {
        get {
            return UInt(userDefaults.integer(forKey: Keys.doubleClickHotkeyModifiers))
        }
        set {
            userDefaults.set(newValue, forKey: Keys.doubleClickHotkeyModifiers)
        }
    }

    // MARK: - Validation

    func validateTencentCredentials() -> (isValid: Bool, error: String?) {
        guard !tencentSecretId.isEmpty else {
            return (false, "Secret ID is empty")
        }

        guard !tencentSecretKey.isEmpty else {
            return (false, "Secret Key is empty")
        }

        guard tencentSecretId.count >= 10 else {
            return (false, "Secret ID is too short")
        }

        guard tencentSecretKey.count >= 10 else {
            return (false, "Secret Key is too short")
        }

        return (true, nil)
    }

    // MARK: - Reset

    func resetTencentCredentials() {
        tencentSecretId = ""
        tencentSecretKey = ""
        tencentRegion = "ap-chengdu"
    }

    func resetHotkeys() {
        // 默认 Alt+S (keyCode=1)
        captureHotkeyKeyCode = 1
        captureHotkeyModifiers = NSEvent.ModifierFlags.option.rawValue

        // 默认 Alt+X (keyCode=7)
        doubleClickHotkeyKeyCode = 7
        doubleClickHotkeyModifiers = NSEvent.ModifierFlags.option.rawValue
    }

    func resetToDefaults() {
        resetTencentCredentials()
    }
}
