import Foundation

struct EnvVariable: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var value: String
    /// Line index in ~/.zshrc (nil for newly added vars not yet saved)
    var lineIndex: Int?

    /// Returns masked display value based on content type.
    /// - URLs (http/https) and paths (/) are shown in full.
    /// - Short values (<=8 chars) are fully masked.
    /// - Long values show first 4 + dots + last 4.
    var maskedValue: String {
        if value.hasPrefix("http://") || value.hasPrefix("https://") || value.hasPrefix("/") {
            return value
        }
        if value.count <= 8 {
            return String(repeating: "\u{2022}", count: 8)
        }
        let prefix = value.prefix(4)
        let suffix = value.suffix(4)
        return "\(prefix)\(String(repeating: "\u{2022}", count: 8))\(suffix)"
    }

    /// Whether this value is a URL (displayed in blue, not masked).
    var isURL: Bool {
        value.hasPrefix("http://") || value.hasPrefix("https://")
    }

    /// Whether this value is a file path (displayed normally, not masked).
    var isPath: Bool {
        value.hasPrefix("/")
    }
}
