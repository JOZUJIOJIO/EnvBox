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

@Test func parseMultilineDescription() {
    let content = """
    ---
    name: browse
    description: |
      Fast headless browser for QA testing.
      Navigate any URL, interact with elements.
    allowed-tools:
      - Bash
    ---
    """
    let result = SkillService.parseFrontmatter(from: content)
    #expect(result?.name == "browse")
    #expect(result?.description.hasPrefix("Fast headless browser") == true)
    #expect(result?.description.contains("Navigate any URL") == true)
}

@Test func parseFoldedDescription() {
    let content = """
    ---
    name: careful
    description: >
      Safety guardrails for destructive commands.
      Warns before rm -rf and force-push.
    ---
    """
    let result = SkillService.parseFrontmatter(from: content)
    #expect(result?.name == "careful")
    #expect(result?.description.hasPrefix("Safety guardrails") == true)
}
