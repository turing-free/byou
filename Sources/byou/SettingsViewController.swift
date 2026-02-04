import Cocoa
import AppKit

class SettingsViewController: NSViewController {

    private var secretIdTextField: NSTextField!
    private var secretKeyTextField: NSSecureTextField!
    private var regionComboBox: NSComboBox!
    private var saveButton: NSButton!
    private var testButton: NSButton!
    private var statusLabel: NSTextField!
    private var closeButton: NSButton!

    private var headerContainer: NSView!
    private var contentContainer: NSView!
    private var footerContainer: NSView!

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 380, height: 450))

        setupUI()
        loadCurrentSettings()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        if let window = view.window {
            window.makeFirstResponder(secretIdTextField)
            DebugLog.debug("Settings window appeared, setting first responder to Secret ID field")
        }
    }

    private func setupUI() {
        setupHeaderView()
        setupContentView()
        setupFooterView()

        NSLayoutConstraint.activate([
            headerContainer.topAnchor.constraint(equalTo: view.topAnchor),
            headerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerContainer.heightAnchor.constraint(equalToConstant: 90),

            contentContainer.topAnchor.constraint(equalTo: headerContainer.bottomAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: footerContainer.topAnchor),

            footerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            footerContainer.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func setupHeaderView() {
        headerContainer = NSView()
        headerContainer.wantsLayer = true
        headerContainer.translatesAutoresizingMaskIntoConstraints = false

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            NSColor(hex: "#667eea").cgColor,
            NSColor(hex: "#764ba2").cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        headerContainer.layer = gradientLayer

        let iconImageView = NSImageView()
        if #available(macOS 11.0, *) {
            let config = NSImage.SymbolConfiguration(pointSize: 40, weight: .regular)
            if let image = NSImage(systemSymbolName: "globe.asia.australia.fill", accessibilityDescription: nil) {
                iconImageView.image = image.withSymbolConfiguration(config)
            }
        }
        iconImageView.contentTintColor = .white
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = NSTextField()
        titleLabel.stringValue = "byou 翻译设置"
        titleLabel.isEditable = false
        titleLabel.isBordered = false
        titleLabel.backgroundColor = .clear
        titleLabel.font = NSFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLabel = NSTextField()
        subtitleLabel.stringValue = "配置腾讯云翻译服务"
        subtitleLabel.isEditable = false
        subtitleLabel.isBordered = false
        subtitleLabel.backgroundColor = .clear
        subtitleLabel.font = NSFont.systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = NSColor.white.withAlphaComponent(0.8)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        headerContainer.addSubview(iconImageView)
        headerContainer.addSubview(titleLabel)
        headerContainer.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 30),
            iconImageView.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),

            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 15),
            titleLabel.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 25),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4)
        ])

        view.addSubview(headerContainer)
    }

    private func setupContentView() {
        contentContainer = NSView()
        contentContainer.wantsLayer = true
        contentContainer.layer?.backgroundColor = NSColor(hex: "#F5F5F7").cgColor
        contentContainer.translatesAutoresizingMaskIntoConstraints = false

        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .leading

        let groupTitle = createGroupLabel("账号配置")
        stackView.addArrangedSubview(groupTitle)

        let divider1 = createDivider()
        stackView.addArrangedSubview(divider1)

        stackView.addArrangedSubview(createFormLabel("Secret ID", icon: "key.fill"))
        secretIdTextField = createTextField(placeholder: "Tencent Cloud Secret ID", icon: "key.fill")
        stackView.addArrangedSubview(secretIdTextField)

        stackView.addArrangedSubview(createFormLabel("Secret Key", icon: "lock.fill"))
        secretKeyTextField = createSecureTextField(placeholder: "Tencent Cloud Secret Key", icon: "lock.fill")
        stackView.addArrangedSubview(secretKeyTextField)

        stackView.addArrangedSubview(createFormLabel("Region", icon: "globe"))
        regionComboBox = createComboBox(items: ["ap-chengdu", "ap-guangzhou", "ap-shanghai", "ap-beijing", "ap-singapore", "us-east-1"], icon: "globe")
        stackView.addArrangedSubview(regionComboBox)

        contentContainer.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -30)
        ])

        view.addSubview(contentContainer)
    }

    private func setupFooterView() {
        footerContainer = NSView()
        footerContainer.wantsLayer = true
        footerContainer.layer?.backgroundColor = .white
        footerContainer.translatesAutoresizingMaskIntoConstraints = false

        let divider = createDivider()
        footerContainer.addSubview(divider)

        statusLabel = NSTextField()
        statusLabel.isEditable = false
        statusLabel.isBordered = false
        statusLabel.backgroundColor = .clear
        statusLabel.font = NSFont.systemFont(ofSize: 12)
        statusLabel.textColor = .secondaryLabelColor
        statusLabel.stringValue = ""
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        footerContainer.addSubview(statusLabel)

        testButton = NSButton(title: "Test Connection", target: self, action: #selector(testConnection))
        testButton.bezelStyle = .rounded
        testButton.translatesAutoresizingMaskIntoConstraints = false
        footerContainer.addSubview(testButton)

        saveButton = NSButton(title: "Save", target: self, action: #selector(saveConfiguration))
        saveButton.bezelStyle = .rounded
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        footerContainer.addSubview(saveButton)

        NSLayoutConstraint.activate([
            divider.topAnchor.constraint(equalTo: footerContainer.topAnchor),
            divider.leadingAnchor.constraint(equalTo: footerContainer.leadingAnchor, constant: 30),
            divider.trailingAnchor.constraint(equalTo: footerContainer.trailingAnchor, constant: -30),

            statusLabel.leadingAnchor.constraint(equalTo: footerContainer.leadingAnchor, constant: 30),
            statusLabel.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor),

            saveButton.trailingAnchor.constraint(equalTo: footerContainer.trailingAnchor, constant: -30),
            saveButton.centerYAnchor.constraint(equalTo: footerContainer.centerYAnchor, constant: 2),
            saveButton.widthAnchor.constraint(equalToConstant: 80),

            testButton.trailingAnchor.constraint(equalTo: saveButton.leadingAnchor, constant: -10),
            testButton.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor),
            testButton.widthAnchor.constraint(equalToConstant: 110)
        ])

        view.addSubview(footerContainer)
    }

    private func createGroupLabel(_ text: String) -> NSTextField {
        let label = NSTextField()
        label.stringValue = text
        label.isEditable = false
        label.isBordered = false
        label.backgroundColor = .clear
        label.font = NSFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = NSColor.secondaryLabelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func createFormLabel(_ text: String, icon: String) -> NSTextField {
        let container = NSStackView()
        container.orientation = .horizontal
        container.spacing = 6
        container.translatesAutoresizingMaskIntoConstraints = false

        let iconView = NSImageView()
        if #available(macOS 11.0, *) {
            let config = NSImage.SymbolConfiguration(pointSize: 13, weight: .regular)
            if let image = NSImage(systemSymbolName: icon, accessibilityDescription: nil) {
                iconView.image = image.withSymbolConfiguration(config)
            }
        }
        iconView.contentTintColor = .secondaryLabelColor
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let label = NSTextField()
        label.stringValue = text
        label.isEditable = false
        label.isBordered = false
        label.backgroundColor = .clear
        label.font = NSFont.systemFont(ofSize: 13)
        label.textColor = .labelColor
        label.translatesAutoresizingMaskIntoConstraints = false

        container.addArrangedSubview(iconView)
        container.addArrangedSubview(label)

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16)
        ])

        let wrapper = NSView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(container)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: wrapper.topAnchor),
            container.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
            wrapper.heightAnchor.constraint(equalToConstant: 20)
        ])

        return label
    }

    private func createTextField(placeholder: String, icon: String) -> NSTextField {
        let textField = NSTextField()
        textField.placeholderString = placeholder
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.widthAnchor.constraint(equalToConstant: 320).isActive = true
        textField.isEditable = true
        textField.isSelectable = true
        textField.wantsLayer = true
        textField.layer?.cornerRadius = 6
        textField.layer?.borderWidth = 1
        textField.layer?.borderColor = NSColor(hex: "#DDDDDD").cgColor
        textField.focusRingType = .none

        return textField
    }

    private func createSecureTextField(placeholder: String, icon: String) -> NSSecureTextField {
        let textField = NSSecureTextField()
        textField.placeholderString = placeholder
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.widthAnchor.constraint(equalToConstant: 320).isActive = true
        textField.isEditable = true
        textField.isSelectable = true
        textField.wantsLayer = true
        textField.layer?.cornerRadius = 6
        textField.layer?.borderWidth = 1
        textField.layer?.borderColor = NSColor(hex: "#DDDDDD").cgColor
        textField.focusRingType = .none

        return textField
    }

    private func createComboBox(items: [String], icon: String) -> NSComboBox {
        let comboBox = NSComboBox()
        comboBox.addItems(withObjectValues: items)
        comboBox.translatesAutoresizingMaskIntoConstraints = false
        comboBox.widthAnchor.constraint(equalToConstant: 320).isActive = true
        comboBox.wantsLayer = true
        comboBox.layer?.cornerRadius = 6
        comboBox.layer?.borderWidth = 1
        comboBox.layer?.borderColor = NSColor(hex: "#DDDDDD").cgColor
        return comboBox
    }

    private func createDivider() -> NSView {
        let divider = NSView()
        divider.wantsLayer = true
        divider.layer?.backgroundColor = NSColor(hex: "#E0E0E0").cgColor
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return divider
    }

    private func loadCurrentSettings() {
        secretIdTextField.stringValue = ConfigManager.shared.tencentSecretId
        secretKeyTextField.stringValue = ConfigManager.shared.tencentSecretKey
        regionComboBox.stringValue = ConfigManager.shared.tencentRegion
    }

    @objc private func saveConfiguration() {
        let secretId = secretIdTextField.stringValue.trimmingCharacters(in: .whitespaces)
        let secretKey = secretKeyTextField.stringValue.trimmingCharacters(in: .whitespaces)
        let region = regionComboBox.stringValue

        ConfigManager.shared.tencentSecretId = secretId
        ConfigManager.shared.tencentSecretKey = secretKey
        ConfigManager.shared.tencentRegion = region

        updateStatus("✓ 配置已保存", color: NSColor(hex: "#34C759"))
        DebugLog.debug("Configuration saved")
    }

    @objc private func testConnection() {
        let secretId = secretIdTextField.stringValue.trimmingCharacters(in: .whitespaces)
        let secretKey = secretKeyTextField.stringValue.trimmingCharacters(in: .whitespaces)

        guard !secretId.isEmpty && !secretKey.isEmpty else {
            updateStatus("✕ 请输入 Secret ID 和 Secret Key", color: NSColor(hex: "#FF3B30"))
            DebugLog.debug("Credentials empty")
            return
        }

        updateStatus("⟳ 测试连接中...", color: NSColor(hex: "#007AFF"))
        saveButton.isEnabled = false
        testButton.isEnabled = false

        DebugLog.debug("Testing with credentials...")

        Task {
            let tempManager = TencentTranslationManager()

            ConfigManager.shared.tencentSecretId = secretId
            ConfigManager.shared.tencentSecretKey = secretKey

            let result = await tempManager.translate("Hello", sourceLang: "en", targetLang: "zh")

            await MainActor.run {
                self.saveButton.isEnabled = true
                self.testButton.isEnabled = true

                if result != nil {
                    self.updateStatus("✓ 测试成功", color: NSColor(hex: "#34C759"))
                    DebugLog.debug("test succeeded")
                } else {
                    self.updateStatus("✕ 测试失败，请检查凭证", color: NSColor(hex: "#FF3B30"))
                    DebugLog.debug("test failed")
                }
            }
        }
    }

    @objc private func closeWindow() {
        view.window?.close()
        DebugLog.debug("Settings window closed")
    }

    private func updateStatus(_ message: String, color: NSColor) {
        statusLabel.stringValue = message
        statusLabel.textColor = color
    }
}

extension NSColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
