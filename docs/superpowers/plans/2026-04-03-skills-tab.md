# Skills Tab Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a Skills tab to EnvBox that scans local directories and displays all installed Claude Code skills with name and description.

**Architecture:** A `SkillService` scans three directories for `SKILL.md` files and parses YAML frontmatter. A `SkillListView` displays the results. `ContentView` gets a top-level tab bar switching between API Keys and Skills.

**Tech Stack:** Swift 6.3, SwiftUI (existing EnvBox project)

---

## File Structure

```
EnvBox/Sources/
├── Models/
│   ├── EnvVariable.swift        # (existing, unchanged)
│   └── Skill.swift              # NEW: Skill data model
├── Services/
│   ├── ZshrcService.swift       # (existing, unchanged)
│   └── SkillService.swift       # NEW: Scan dirs, parse SKILL.md
└── Views/
    ├── ContentView.swift        # MODIFY: Add tab bar
    ├── EnvListView.swift        # (existing, unchanged)
    ├── AddEnvView.swift         # (existing, unchanged)
    ├── EditEnvView.swift        # (existing, unchanged)
    └── SkillListView.swift      # NEW: Skill list UI

EnvBox/Tests/
└── SkillServiceTests.swift      # NEW: Tests for parsing
```

---

### Task 1: Skill Model + SkillService with Tests

**Files:**
- Create: `EnvBox/Sources/Models/Skill.swift`
- Create: `EnvBox/Sources/Services/SkillService.swift`
- Create: `EnvBox/Tests/SkillServiceTests.swift`

- [ ] **Step 1: Create Skill model**

```swift
// Sources/Models/Skill.swift
import Foundation

struct Skill: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let source: String  // "user", "superpowers", "custom"
}
```

- [ ] **Step 2: Write failing tests for frontmatter parsing**

```swift
// Tests/SkillServiceTests.swift
import Testing
import Foundation
@testable import EnvBox

@Test func parseQuotedFrontmatter() {
    let content = """
    ---
    name: "screenshot"
    description: "Use when the user asks for a screenshot"
    ---
    # Screenshot
    Some content
    """
    let result = SkillService.parseFrontmatter(from: content)
    #expect(result?.name == "screenshot")
    #expect(result?.description == "Use when the user asks for a screenshot")
}

@Test func parseUnquotedFrontmatter() {
    let content = """
    ---
    name: test-driven-development
    description: Use when implementing any feature or bugfix
    ---
    # TDD
    """
    let result = SkillService.parseFrontmatter(from: content)
    #expect(result?.name == "test-driven-development")
    #expect(result?.description == "Use when implementing any feature or bugfix")
}

@Test func parseChineseFrontmatter() {
    let content = """
    ---
    name: daily-tech-news
    description: 每日科技新闻自动采集与公众号发布
    ---
    """
    let result = SkillService.parseFrontmatter(from: content)
    #expect(result?.name == "daily-tech-news")
    #expect(result?.description == "每日科技新闻自动采集与公众号发布")
}

@Test func parseInvalidFrontmatter() {
    let content = "# No frontmatter here\nJust markdown"
    let result = SkillService.parseFrontmatter(from: content)
    #expect(result == nil)
}

@Test func parseFrontmatterMissingName() {
    let content = """
    ---
    description: "Has description but no name"
    ---
    """
    let result = SkillService.parseFrontmatter(from: content)
    #expect(result == nil)
}

@Test func parseLongDescription() {
    // description may be very long, we truncate to first sentence/line for display
    let content = """
    ---
    name: browse
    description: "Fast headless browser for QA testing and site dogfooding. Navigate any URL, interact with elements, verify page state."
    ---
    """
    let result = SkillService.parseFrontmatter(from: content)
    #expect(result?.name == "browse")
    #expect(result?.description.hasPrefix("Fast headless browser") == true)
}
```

- [ ] **Step 3: Run tests to verify they fail**

```bash
swift test
```
Expected: Compilation error — `SkillService` does not exist.

- [ ] **Step 4: Implement SkillService**

```swift
// Sources/Services/SkillService.swift
import Foundation

struct ParsedSkillMeta {
    let name: String
    let description: String
}

class SkillService {
    /// Parse YAML frontmatter from SKILL.md content.
    /// Returns nil if frontmatter is missing or name is not found.
    static func parseFrontmatter(from content: String) -> ParsedSkillMeta? {
        let lines = content.components(separatedBy: "\n")

        // Find opening and closing ---
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

    /// Extract value from a "key: value" or 'key: "value"' YAML line.
    private static func extractYAMLValue(from line: String) -> String {
        guard let colonIdx = line.firstIndex(of: ":") else { return "" }
        var value = String(line[line.index(after: colonIdx)...]).trimmingCharacters(in: .whitespaces)
        // Remove surrounding quotes
        if (value.hasPrefix("\"") && value.hasSuffix("\"")) ||
           (value.hasPrefix("'") && value.hasSuffix("'")) {
            value = String(value.dropFirst().dropLast())
        }
        return value
    }

    /// Scan a directory for skill subdirectories containing SKILL.md.
    /// Returns array of Skills with the given source label.
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

    /// Load all skills from the three known directories.
    static func loadAllSkills() -> [Skill] {
        let home = NSHomeDirectory()

        // 1. User-installed skills
        let userSkills = scanDirectory(at: "\(home)/.claude/skills", source: "user")

        // 2. Superpowers skills — find latest version
        let superpowersBase = "\(home)/.claude/plugins/cache/claude-plugins-official/superpowers"
        var superpowersSkills: [Skill] = []
        if let versions = try? FileManager.default.contentsOfDirectory(atPath: superpowersBase) {
            // Pick the latest version directory
            if let latestVersion = versions.filter({ !$0.hasPrefix(".") }).sorted().last {
                superpowersSkills = scanDirectory(at: "\(superpowersBase)/\(latestVersion)/skills", source: "superpowers")
            }
        }

        // 3. Custom skills
        let customSkills = scanDirectory(at: "\(home)/SKILLS", source: "custom")

        return userSkills + superpowersSkills + customSkills
    }
}
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
swift test
```
Expected: All tests pass (existing 16 + new 6 = 22 tests).

- [ ] **Step 6: Commit**

```bash
git add Sources/Models/Skill.swift Sources/Services/SkillService.swift Tests/SkillServiceTests.swift
git commit -m "feat: add Skill model and SkillService with frontmatter parsing"
```

---

### Task 2: SkillListView

**Files:**
- Create: `EnvBox/Sources/Views/SkillListView.swift`

- [ ] **Step 1: Create SkillListView**

```swift
// Sources/Views/SkillListView.swift
import SwiftUI

struct SkillListView: View {
    @Binding var skills: [Skill]
    @Binding var searchText: String

    private var filtered: [Skill] {
        if searchText.isEmpty { return skills }
        return skills.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    TextField("搜索...", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.controlBackgroundColor))
                .cornerRadius(6)

                Spacer()

                Text("\(skills.count) 个技能")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Divider()

            // Skill list
            ScrollView {
                LazyVStack(spacing: 2) {
                    ForEach(filtered) { skill in
                        SkillRowView(skill: skill)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }

            Divider()

            // Footer
            HStack {
                Text("来源: ~/.claude/skills · superpowers · ~/SKILLS")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
        }
    }
}

struct SkillRowView: View {
    let skill: Skill

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(skill.name)
                    .font(.system(size: 13, weight: .medium))
                Spacer()
                Text(skill.source)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(4)
            }
            Text(skill.description)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.controlBackgroundColor).opacity(0.5))
        .cornerRadius(8)
    }
}
```

- [ ] **Step 2: Build to verify it compiles**

```bash
swift build
```
Expected: Build succeeds (SkillListView is not yet used by ContentView, but should compile).

- [ ] **Step 3: Commit**

```bash
git add Sources/Views/SkillListView.swift
git commit -m "feat: add SkillListView for displaying installed skills"
```

---

### Task 3: Wire Up Tab Bar in ContentView

**Files:**
- Modify: `EnvBox/Sources/Views/ContentView.swift`

- [ ] **Step 1: Replace ContentView.swift with tab-based navigation**

```swift
// Sources/Views/ContentView.swift
import SwiftUI

enum AppTab {
    case apiKeys
    case skills
}

enum EnvViewState {
    case list
    case add
    case edit(EnvVariable)
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .apiKeys
    @State private var envViewState: EnvViewState = .list
    @State private var variables: [EnvVariable] = []
    @State private var envSearchText = ""
    @State private var skills: [Skill] = []
    @State private var skillSearchText = ""

    var body: some View {
        VStack(spacing: 0) {
            // Tab bar
            HStack(spacing: 0) {
                TabButton(
                    title: "🔑 API Keys",
                    isSelected: selectedTab == .apiKeys,
                    action: { selectedTab = .apiKeys }
                )
                TabButton(
                    title: "⚡ Skills",
                    isSelected: selectedTab == .skills,
                    action: { selectedTab = .skills }
                )
            }

            // Content
            switch selectedTab {
            case .apiKeys:
                apiKeysContent
            case .skills:
                SkillListView(skills: $skills, searchText: $skillSearchText)
            }
        }
        .frame(width: 420, height: 500)
        .onAppear {
            variables = ZshrcService.loadVariables()
            skills = SkillService.loadAllSkills()
        }
    }

    @ViewBuilder
    private var apiKeysContent: some View {
        switch envViewState {
        case .list:
            EnvListView(
                variables: $variables,
                searchText: $envSearchText,
                onAdd: { envViewState = .add },
                onEdit: { envVar in envViewState = .edit(envVar) }
            )
        case .add:
            AddEnvView(
                variables: variables,
                onSave: { reloadEnv(); envViewState = .list },
                onCancel: { envViewState = .list }
            )
        case .edit(let envVar):
            EditEnvView(
                envVar: envVar,
                onSave: { reloadEnv(); envViewState = .list },
                onDelete: { reloadEnv(); envViewState = .list },
                onCancel: { envViewState = .list }
            )
        }
    }

    private func reloadEnv() {
        variables = ZshrcService.loadVariables()
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .accentColor : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                Rectangle()
                    .fill(isSelected ? Color.accentColor : Color.clear)
                    .frame(height: 2)
            }
        }
        .buttonStyle(.plain)
    }
}
```

- [ ] **Step 2: Build and verify**

```bash
swift build
```
Expected: Build succeeds.

- [ ] **Step 3: Run all tests**

```bash
swift test
```
Expected: All 22 tests pass.

- [ ] **Step 4: Commit**

```bash
git add Sources/Views/ContentView.swift
git commit -m "feat: add tab bar switching between API Keys and Skills"
```

- [ ] **Step 5: Rebuild release and install**

```bash
make install
```
Expected: Updated app installed to `/Applications/`. Launch it — tab bar visible at top, clicking Skills shows all installed skills.
