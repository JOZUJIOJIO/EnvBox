import Testing
@testable import EnvBox

@Suite("EnvVariable Tests")
struct EnvVariableTests {
    @Test func maskedValueHidesShortSecrets() {
        let v = EnvVariable(name: "KEY", value: "abc")
        #expect(v.maskedValue == "\u{2022}\u{2022}\u{2022}\u{2022}\u{2022}\u{2022}\u{2022}\u{2022}")
    }

    @Test func maskedValueShowsURLs() {
        let v = EnvVariable(name: "URL", value: "https://example.com")
        #expect(v.maskedValue == "https://example.com")
    }

    @Test func maskedValueShowsPaths() {
        let v = EnvVariable(name: "PATH", value: "/usr/local/bin")
        #expect(v.maskedValue == "/usr/local/bin")
    }

    @Test func maskedValuePartiallyHidesLongSecrets() {
        let v = EnvVariable(name: "KEY", value: "sk-1234567890abcdef")
        #expect(v.maskedValue.hasPrefix("sk-1"))
        #expect(v.maskedValue.hasSuffix("cdef"))
    }
}
