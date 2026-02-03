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

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 500, height: 400))

        setupUI()
        loadCurrentSettings()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        if let window = view.window {
            window.makeFirstResponder(secretIdTextField)
            print("Settings window appeared, setting first responder to Secret ID field")
        }
    }

    private func setupUI() {
        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .leading

        stackView.addArrangedSubview(createSectionTitle("Tencent Cloud Translation"))

        stackView.addArrangedSubview(createLabel("Secret ID:"))
        secretIdTextField = createTextField(placeholder: "Enter your Tencent Cloud Secret ID")
        stackView.addArrangedSubview(secretIdTextField)

        stackView.addArrangedSubview(createLabel("Secret Key:"))
        secretKeyTextField = createSecureTextField(placeholder: "Enter your Tencent Cloud Secret Key")
        stackView.addArrangedSubview(secretKeyTextField)

        stackView.addArrangedSubview(createLabel("Region:"))
        regionComboBox = createComboBox(items: ["ap-chengdu", "ap-guangzhou", "ap-shanghai", "ap-beijing", "ap-singapore", "us-east-1"])
        stackView.addArrangedSubview(regionComboBox)

        statusLabel = NSTextField()
        statusLabel.isEditable = false
        statusLabel.isBordered = false
        statusLabel.backgroundColor = .clear
        statusLabel.font = NSFont.systemFont(ofSize: 11)
        statusLabel.textColor = .secondaryLabelColor
        statusLabel.stringValue = ""
        stackView.addArrangedSubview(statusLabel)

        let buttonStackView = NSStackView()
        buttonStackView.orientation = .horizontal
        buttonStackView.spacing = 10

        saveButton = NSButton(title: "Save Configuration", target: self, action: #selector(saveConfiguration))
        saveButton.bezelStyle = .rounded
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        testButton = NSButton(title: "Test Connection", target: self, action: #selector(testConnection))
        testButton.bezelStyle = .rounded
        testButton.translatesAutoresizingMaskIntoConstraints = false

        closeButton = NSButton(title: "Close", target: self, action: #selector(closeWindow))
        closeButton.bezelStyle = .rounded
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        buttonStackView.addArrangedSubview(saveButton)
        buttonStackView.addArrangedSubview(testButton)
        buttonStackView.addArrangedSubview(closeButton)

        stackView.addArrangedSubview(buttonStackView)

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])
    }

    private func createSectionTitle(_ text: String) -> NSTextField {
        let label = NSTextField()
        label.stringValue = text
        label.isEditable = false
        label.isBordered = false
        label.backgroundColor = .clear
        label.font = NSFont.boldSystemFont(ofSize: 14)
        label.textColor = .labelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 440).isActive = true
        return label
    }

    private func createLabel(_ text: String) -> NSTextField {
        let label = NSTextField()
        label.stringValue = text
        label.isEditable = false
        label.isBordered = false
        label.backgroundColor = .clear
        label.font = NSFont.systemFont(ofSize: 13)
        label.textColor = .labelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 440).isActive = true
        return label
    }

    private func createTextField(placeholder: String) -> NSTextField {
        let textField = NSTextField()
        textField.placeholderString = placeholder
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.widthAnchor.constraint(equalToConstant: 440).isActive = true
        textField.isEditable = true
        textField.isSelectable = true
        return textField
    }

    private func createSecureTextField(placeholder: String) -> NSSecureTextField {
        let textField = NSSecureTextField()
        textField.placeholderString = placeholder
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.widthAnchor.constraint(equalToConstant: 440).isActive = true
        textField.isEditable = true
        textField.isSelectable = true
        return textField
    }

    private func createComboBox(items: [String]) -> NSComboBox {
        let comboBox = NSComboBox()
        comboBox.addItems(withObjectValues: items)
        comboBox.translatesAutoresizingMaskIntoConstraints = false
        comboBox.widthAnchor.constraint(equalToConstant: 440).isActive = true
        return comboBox
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

        updateStatus("Configuration saved successfully!", color: .systemGreen)
        print("Configuration saved")
    }

    @objc private func testConnection() {
        let secretId = secretIdTextField.stringValue.trimmingCharacters(in: .whitespaces)
        let secretKey = secretKeyTextField.stringValue.trimmingCharacters(in: .whitespaces)

        guard !secretId.isEmpty && !secretKey.isEmpty else {
            updateStatus("Please enter Secret ID and Secret Key", color: .systemRed)
            print("Credentials empty")
            return
        }

        updateStatus("Testing connection...", color: .labelColor)
        saveButton.isEnabled = false
        testButton.isEnabled = false

        print("Testing connection with credentials...")

        Task {
            let tempManager = TencentTranslationManager()

            ConfigManager.shared.tencentSecretId = secretId
            ConfigManager.shared.tencentSecretKey = secretKey

            let result = await tempManager.translate("Hello", sourceLang: "en", targetLang: "zh")

            await MainActor.run {
                self.saveButton.isEnabled = true
                self.testButton.isEnabled = true

                if result != nil {
                    self.updateStatus("Connection test successful!", color: .systemGreen)
                    print("Connection test succeeded")
                } else {
                    self.updateStatus("Connection test failed. Please check your credentials.", color: .systemRed)
                    print("Connection test failed")
                }
            }
        }
    }

    @objc private func closeWindow() {
        view.window?.close()
        print("Settings window closed")
    }

    private func updateStatus(_ message: String, color: NSColor) {
        statusLabel.stringValue = message
        statusLabel.textColor = color
    }
}
