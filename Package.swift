// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AIVault",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "AIVault",
            path: "Sources"
        ),
        .testTarget(
            name: "AIVaultTests",
            dependencies: ["AIVault"],
            path: "Tests"
        ),
    ]
)
