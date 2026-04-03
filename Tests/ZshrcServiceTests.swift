import Testing
import Foundation
@testable import AIVault

@Test func parseDoubleQuotedExport() {
    let content = """
    export MY_KEY="some-value"
    """
    let vars = ZshrcService.parseExports(from: content)
    #expect(vars.count == 1)
    #expect(vars[0].name == "MY_KEY")
    #expect(vars[0].value == "some-value")
    #expect(vars[0].lineIndex == 0)
}

@Test func parseSingleQuotedExport() {
    let content = """
    export MY_KEY='some-value'
    """
    let vars = ZshrcService.parseExports(from: content)
    #expect(vars.count == 1)
    #expect(vars[0].value == "some-value")
}

@Test func parseUnquotedExport() {
    let content = """
    export MY_KEY=some-value
    """
    let vars = ZshrcService.parseExports(from: content)
    #expect(vars.count == 1)
    #expect(vars[0].value == "some-value")
}

@Test func skipCommentedExport() {
    let content = """
    # export OLD_KEY="old-value"
    export ACTIVE_KEY="active"
    """
    let vars = ZshrcService.parseExports(from: content)
    #expect(vars.count == 1)
    #expect(vars[0].name == "ACTIVE_KEY")
}

@Test func skipPathExport() {
    let content = """
    export PATH="$PATH:/usr/local/bin"
    export PATH=/usr/bin:$PATH
    export MY_KEY="value"
    """
    let vars = ZshrcService.parseExports(from: content)
    #expect(vars.count == 1)
    #expect(vars[0].name == "MY_KEY")
}

@Test func parseMultipleExports() {
    let content = """
    if command -v pyenv 1>/dev/null 2>&1; then
      eval "$(pyenv init -)"
    fi
    export GEMINI_API_KEY="AIzaSy123"
    export ANTHROPIC_API_KEY="sk-abc123"
    export ANTHROPIC_BASE_URL="https://www.example.com"
    """
    let vars = ZshrcService.parseExports(from: content)
    #expect(vars.count == 3)
    #expect(vars[0].name == "GEMINI_API_KEY")
    #expect(vars[0].lineIndex == 3)
    #expect(vars[1].name == "ANTHROPIC_API_KEY")
    #expect(vars[2].name == "ANTHROPIC_BASE_URL")
    #expect(vars[2].value == "https://www.example.com")
}

@Test func addVariable() {
    let original = """
    export EXISTING="value1"
    """
    let result = ZshrcService.addExport(to: original, name: "NEW_KEY", value: "new-value")
    #expect(result.contains(#"export NEW_KEY="new-value""#))
    #expect(result.contains(#"export EXISTING="value1""#))
}

@Test func addVariableWithBaseURL() {
    let original = "export EXISTING=\"value1\"\n"
    let result = ZshrcService.addExport(to: original, name: "OPENAI_API_KEY", value: "sk-123", baseURL: "https://api.openai.com")
    #expect(result.contains(#"export OPENAI_API_KEY="sk-123""#))
    #expect(result.contains(#"export OPENAI_BASE_URL="https://api.openai.com""#))
}

@Test func addVariableBaseURLNaming() {
    let result = ZshrcService.addExport(to: "", name: "ANTHROPIC_API_KEY", value: "sk-x", baseURL: "https://example.com")
    #expect(result.contains(#"export ANTHROPIC_BASE_URL="https://example.com""#))
}

@Test func updateVariable() {
    let original = """
    some other line
    export MY_KEY="old-value"
    another line
    """
    let result = ZshrcService.updateExport(in: original, lineIndex: 1, newValue: "new-value")
    #expect(result.contains(#"export MY_KEY="new-value""#))
    #expect(result.contains("some other line"))
    #expect(result.contains("another line"))
    #expect(!result.contains("old-value"))
}

@Test func deleteVariable() {
    let original = """
    line zero
    export MY_KEY="to-delete"
    line two
    """
    let result = ZshrcService.deleteExport(from: original, lineIndex: 1)
    #expect(!result.contains("MY_KEY"))
    #expect(result.contains("line zero"))
    #expect(result.contains("line two"))
}

@Test func addVariableDuplicateDetection() {
    let content = """
    export MY_KEY="existing"
    """
    let vars = ZshrcService.parseExports(from: content)
    let hasDuplicate = vars.contains { $0.name == "MY_KEY" }
    #expect(hasDuplicate)
}
