import Foundation

struct Skill: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let source: String  // "user", "superpowers", "custom"
}
