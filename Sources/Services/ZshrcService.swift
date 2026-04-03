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

    /// Read and parse ~/.zshrc. Returns empty array if file doesn't exist.
    static func loadVariables() -> [EnvVariable] {
        guard let content = try? String(contentsOfFile: zshrcPath, encoding: .utf8) else {
            return []
        }
        return parseExports(from: content)
    }
}
