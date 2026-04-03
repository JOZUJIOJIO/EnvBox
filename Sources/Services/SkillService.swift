import Foundation

struct ParsedSkillMeta {
    let name: String
    let description: String
}

class SkillService {
    static func parseFrontmatter(from content: String) -> ParsedSkillMeta? {
        let lines = content.components(separatedBy: "\n")

        guard let firstIdx = lines.firstIndex(where: { $0.trimmingCharacters(in: .whitespaces) == "---" }) else {
            return nil
        }
        let afterFirst = lines.index(after: firstIdx)
        guard afterFirst < lines.endIndex,
              let secondIdx = lines[afterFirst...].firstIndex(where: { $0.trimmingCharacters(in: .whitespaces) == "---" }) else {
            return nil
        }

        let frontmatterLines = lines[afterFirst..<secondIdx]

        var name: String?
        var description: String?

        for line in frontmatterLines {
            if line.trimmingCharacters(in: .whitespaces).hasPrefix("name:") {
                name = extractYAMLValue(from: line)
            } else if line.trimmingCharacters(in: .whitespaces).hasPrefix("description:") {
                description = extractYAMLValue(from: line)
            }
        }

        guard let name, !name.isEmpty else { return nil }
        return ParsedSkillMeta(name: name, description: description ?? "")
    }

    private static func extractYAMLValue(from line: String) -> String {
        guard let colonIdx = line.firstIndex(of: ":") else { return "" }
        var value = String(line[line.index(after: colonIdx)...]).trimmingCharacters(in: .whitespaces)
        if (value.hasPrefix("\"") && value.hasSuffix("\"")) ||
           (value.hasPrefix("'") && value.hasSuffix("'")) {
            value = String(value.dropFirst().dropLast())
        }
        return value
    }

    static func scanDirectory(at path: String, source: String) -> [Skill] {
        let fm = FileManager.default
        guard let entries = try? fm.contentsOfDirectory(atPath: path) else { return [] }

        var skills: [Skill] = []
        for entry in entries {
            let skillMdPath = "\(path)/\(entry)/SKILL.md"
            guard fm.fileExists(atPath: skillMdPath),
                  let content = try? String(contentsOfFile: skillMdPath, encoding: .utf8),
                  let meta = parseFrontmatter(from: content) else {
                continue
            }
            skills.append(Skill(name: meta.name, description: meta.description, source: source))
        }
        return skills.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    static func loadAllSkills() -> [Skill] {
        let home = NSHomeDirectory()

        let userSkills = scanDirectory(at: "\(home)/.claude/skills", source: "user")

        let superpowersBase = "\(home)/.claude/plugins/cache/claude-plugins-official/superpowers"
        var superpowersSkills: [Skill] = []
        if let versions = try? FileManager.default.contentsOfDirectory(atPath: superpowersBase) {
            if let latestVersion = versions.filter({ !$0.hasPrefix(".") }).sorted().last {
                superpowersSkills = scanDirectory(at: "\(superpowersBase)/\(latestVersion)/skills", source: "superpowers")
            }
        }

        let customSkills = scanDirectory(at: "\(home)/SKILLS", source: "custom")

        return userSkills + superpowersSkills + customSkills
    }
}
