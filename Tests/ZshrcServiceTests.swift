import Testing
import Foundation
@testable import EnvBox

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
