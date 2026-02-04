import Foundation
import CommonCrypto

class TencentTranslationManager {
    private let endpoint = "tmt.tencentcloudapi.com"
    private let service = "tmt"
    private let version = "2018-03-21"
    private let action = "TextTranslate"
    private let projectId = 0

    private var secretId: String {
        return ConfigManager.shared.tencentSecretId
    }

    private var secretKey: String {
        return ConfigManager.shared.tencentSecretKey
    }

    private var region: String {
        return ConfigManager.shared.tencentRegion
    }

    func translate(_ text: String, sourceLang: String = "en", targetLang: String = "zh") async -> String? {
        guard !secretId.isEmpty && !secretKey.isEmpty else {
            DebugLog.debug("Tencent credentials not configured")
            return nil
        }

        guard text.count <= 2000 else {
            DebugLog.debug("Text exceeds maximum length of 2000 heracters")
            return nil
        }

        do {
            let result = try await performTranslation(text: text, source: sourceLang, target: targetLang)
            return result
        } catch {
            DebugLog.debug("Translation error: \(error.localizedDescription)")
            return nil
        }
    }

    func translateAndFormat(_ text: String, sourceLang: String = "en", targetLang: String = "zh") async -> String {
        if let translation = await translate(text, sourceLang: sourceLang, targetLang: targetLang) {
            return "\(translation)"
        } else {
            return "Translation (Tencent): Failed to translate '\(text)'"
        }
    }

    private func performTranslation(text: String, source: String, target: String) async throws -> String {
        let maxRetries = 3
        var delay: TimeInterval = 1.0

        for attempt in 0..<maxRetries {
            do {
                return try await performSingleTranslation(text: text, source: source, target: target)
            } catch {
                if attempt < maxRetries - 1 && isRetryableError(error) {
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    delay *= 2
                    continue
                }
                throw error
            }
        }

        throw TranslationError.requestFailed
    }

    private func generateTC3Signature(timestamp: Int, parameters: [String: Any]) -> [String: String] {
        let date = timestampToDateString(timestamp: timestamp)

        let httpRequestMethod = "POST"
        let canonicalUri = "/"
        let canonicalQuerystring = ""
        let ct = "application/json; charset=utf-8"
        let canonicalHeaders = "content-type:\(ct)\nhost:\(endpoint)\nx-tc-action:\(action.lowercased())\n"
        let signedHeaders = "content-type;host;x-tc-action"

        let requestBody = try! JSONSerialization.data(withJSONObject: parameters, options: [.sortedKeys])
        let requestPayload = sha256Data(requestBody).hexString

        let canonicalRequest = """
        \(httpRequestMethod)
        \(canonicalUri)
        \(canonicalQuerystring)
        \(canonicalHeaders)
        \(signedHeaders)
        \(requestPayload)
        """

        let algorithm = "TC3-HMAC-SHA256"
        let credentialScope = "\(date)/\(service)/tc3_request"
        let hashedCanonicalRequest = sha256Hex(canonicalRequest)
        let stringToSign = """
        \(algorithm)
        \(timestamp)
        \(credentialScope)
        \(hashedCanonicalRequest)
        """

        let keyData = Data(("TC3" + secretKey).utf8)
        let dateData = Data(date.utf8)
        let secretDate = hmacSha256Data(keyData: keyData, data: dateData)

        let serviceData = Data(service.utf8)
        let secretService = hmacSha256Data(keyData: secretDate, data: serviceData)

        let signingData = Data("tc3_request".utf8)
        let secretSigning = hmacSha256Data(keyData: secretService, data: signingData)

        let stringToSignData = Data(stringToSign.utf8)
        let signature = hmacSha256Data(keyData: secretSigning, data: stringToSignData).hexString

        let authorization = "\(algorithm) Credential=\(secretId)/\(credentialScope), SignedHeaders=\(signedHeaders), Signature=\(signature)"

        return [
            "Authorization": authorization,
            "Content-Type": ct,
            "Host": endpoint,
            "X-TC-Action": action,
            "X-TC-Timestamp": "\(timestamp)",
            "X-TC-Version": version,
            "X-TC-Region": region
        ]
    }

    private func timestampToDateString(timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func sha256Hex(_ string: String) -> String {
        return sha256Data(string.data(using: .utf8)!).hexString
    }

    private func sha256Data(_ data: Data) -> Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
            _ = CC_SHA256(bytes.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash)
    }

    private func performSingleTranslation(text: String, source: String, target: String) async throws -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let parameters: [String: Any] = [
            "SourceText": text,
            "Source": source,
            "Target": target,
            "ProjectId": projectId
        ]

        let headers = generateTC3Signature(timestamp: timestamp, parameters: parameters)

        var request = URLRequest(url: URL(string: "https://\(endpoint)")!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: [.sortedKeys])

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw TranslationError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw TranslationError.httpError(statusCode: httpResponse.statusCode)
        }

        do {
            let decoded = try JSONDecoder().decode(TencentTranslationResponse.self, from: data)
            return decoded.response.targetText
        } catch {
            // Try to decode as error response
            if let errorResponse = try? JSONDecoder().decode(TencentErrorResponse.self, from: data) {
                throw TranslationError.apiError(code: errorResponse.response.error.code, message: errorResponse.response.error.message)
            }
            throw TranslationError.invalidResponse
        }
    }

    private func hmacSha256(secretKey: String, data: String) -> String {
        let keyData = secretKey.data(using: .utf8)!
        let dataBytes = data.data(using: .utf8)!
        return hmacSha256Data(keyData: keyData, data: dataBytes).hexString
    }

    private func hmacSha256Data(keyData: Data, data: Data) -> Data {
        var hmac = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        keyData.withUnsafeBytes { keyBytes in
            data.withUnsafeBytes { dataBytes in
                CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256),
                        keyBytes.baseAddress, keyData.count,
                        dataBytes.baseAddress, data.count,
                        &hmac)
            }
        }
        return Data(hmac)
    }

    private func isRetryableError(_ error: Error) -> Bool {
        if let translationError = error as? TranslationError {
            switch translationError {
            case .httpError(let statusCode) where statusCode >= 500,
                 .httpError(let statusCode) where statusCode == 429:
                return true
            default:
                return false
            }
        }
        return false
    }
}

extension Data {
    var hexString: String {
        return map { String(format: "%02x", $0) }.joined()
    }
}

private struct TencentTranslationResponse: Codable {
    let response: TranslationData

    struct TranslationData: Codable {
        let targetText: String
        let source: String
        let target: String
        let requestId: String

        enum CodingKeys: String, CodingKey {
            case targetText = "TargetText"
            case source = "Source"
            case target = "Target"
            case requestId = "RequestId"
        }
    }

    enum CodingKeys: String, CodingKey {
        case response = "Response"
    }
}

private struct TencentErrorResponse: Codable {
    let response: ErrorData

    struct ErrorData: Codable {
        let error: ErrorDetail

        struct ErrorDetail: Codable {
            let code: String
            let message: String
        }
    }

    enum CodingKeys: String, CodingKey {
        case response = "Response"
    }
}

enum TranslationError: Error, LocalizedError {
    case credentialsNotConfigured
    case textTooLong
    case invalidResponse
    case httpError(statusCode: Int)
    case apiError(code: String, message: String)
    case requestFailed

    var errorDescription: String? {
        switch self {
        case .credentialsNotConfigured:
            return "Tencent Cloud credentials not configured"
        case .textTooLong:
            return "Text exceeds maximum length of 2000 characters"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .apiError(let code, let message):
            return "API error [\(code)]: \(message)"
        case .requestFailed:
            return "Translation request failed after retries"
        }
    }
}
