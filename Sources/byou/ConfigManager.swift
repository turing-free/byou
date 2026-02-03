import Foundation

/// 配置管理器 - 安全存储应用配置和凭证
class ConfigManager {
    static let shared = ConfigManager()

    private let userDefaults = UserDefaults.standard

    private init() {}

    // MARK: - Tencent Cloud Configuration

    private enum Keys {
        static let tencentSecretId = "tencent.secretId"
        static let tencentSecretKey = "tencent.secretKey"
        static let tencentRegion = "tencent.region"
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

    func resetToDefaults() {
        resetTencentCredentials()
    }
}
