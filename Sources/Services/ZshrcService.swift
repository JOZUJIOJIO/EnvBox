import Foundation

class ZshrcService {
    static let zshrcPath = NSHomeDirectory() + "/.zshrc"

    /// Parse export lines from raw file content.
    /// Returns EnvVariable array, skipping commented lines and PATH assignments.
    static func parseExports(from content: String) -> [EnvVariable] {
        let lines = content.components(separatedBy: "\n")
        var results: [EnvVariable] = []

        // Matches: export KEY="VALUE", export KEY='VALUE', export KEY=VALUE
        let pattern = #"^\s*export\s+([A-Za-z_][A-Za-z0-9_]*)=(?:"([^"]*)"|'([^']*)'|(\S+))"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return results }

        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Skip commented lines
            if trimmed.hasPrefix("#") { continue }

            let range = NSRange(line.startIndex..., in: line)
            guard let match = regex.firstMatch(in: line, range: range) else { continue }

            // Extract variable name
            guard let nameRange = Range(match.range(at: 1), in: line) else { continue }
            let name = String(line[nameRange])

            // Skip PATH-like variables
            if name == "PATH" { continue }

            // Extract value from whichever capture group matched
            var value = ""
            for group in 2...4 {
                if let valueRange = Range(match.range(at: group), in: line) {
                    value = String(line[valueRange])
                    break
                }
            }

            results.append(EnvVariable(name: name, value: value, lineIndex: index))
        }

        return results
    }

    /// Derive base URL variable name from an API key name.
    /// "OPENAI_API_KEY" -> "OPENAI_BASE_URL"
    /// "MY_SERVICE_KEY" -> "MY_SERVICE_BASE_URL"
    /// "RANDOM_NAME" -> "RANDOM_NAME_BASE_URL"
    static func baseURLName(from keyName: String) -> String {
        if keyName.hasSuffix("_API_KEY") {
            return String(keyName.dropLast("_API_KEY".count)) + "_BASE_URL"
        }
        if keyName.hasSuffix("_KEY") {
            return String(keyName.dropLast("_KEY".count)) + "_BASE_URL"
        }
        return keyName + "_BASE_URL"
    }

    /// Add a new export line to the end of the content.
    static func addExport(to content: String, name: String, value: String, baseURL: String? = nil) -> String {
        var result = content
        if !result.isEmpty && !result.hasSuffix("\n") {
            result += "\n"
        }
        result += "export \(name)=\"\(value)\"\n"
        if let baseURL, !baseURL.isEmpty {
            let urlName = baseURLName(from: name)
            result += "export \(urlName)=\"\(baseURL)\"\n"
        }
        return result
    }

    /// Update the value of an export at a specific line index.
    static func updateExport(in content: String, lineIndex: Int, newValue: String) -> String {
        var lines = content.components(separatedBy: "\n")
        guard lineIndex >= 0 && lineIndex < lines.count else { return content }

        let line = lines[lineIndex]
        let pattern = #"^(\s*export\s+[A-Za-z_][A-Za-z0-9_]*)=.*"#
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
           let prefixRange = Range(match.range(at: 1), in: line) {
            lines[lineIndex] = "\(line[prefixRange])=\"\(newValue)\""
        }

        return lines.joined(separator: "\n")
    }

    /// Delete the export line at a specific line index.
    static func deleteExport(from content: String, lineIndex: Int) -> String {
        var lines = content.components(separatedBy: "\n")
        guard lineIndex >= 0 && lineIndex < lines.count else { return content }
        lines.remove(at: lineIndex)
        return lines.joined(separator: "\n")
    }

    /// Write content to ~/.zshrc and source it.
    static func writeAndSource(_ content: String) throws {
        try content.write(toFile: zshrcPath, atomically: true, encoding: .utf8)
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", "source \(zshrcPath)"]
        try? process.run()
    }

    /// Read and parse ~/.zshrc. Returns empty array if file doesn't exist.
    static func loadVariables() -> [EnvVariable] {
        guard let content = try? String(contentsOfFile: zshrcPath, encoding: .utf8) else {
            return []
        }
        return parseExports(from: content)
    }
}
