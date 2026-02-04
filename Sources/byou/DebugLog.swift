import Foundation

/// 调试日志输出工具
/// 在 Debug 模式下输出日志，在 Release 模式下被编译器完全移除
class DebugLog {
    /// 输出调试信息（仅在 Debug 模式）
    /// - Parameter message: 要输出的消息
    static func debug(_ message: String) {
        #if DEBUG
        print(message)
        #endif
    }

    /// 输出错误信息（仅在 Debug 模式）
    /// - Parameter message: 错误消息
    static func error(_ message: String) {
        #if DEBUG
        print("ERROR: \(message)")
        #endif
    }
}
