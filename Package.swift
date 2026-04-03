// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "EnvBox",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "EnvBox",
            path: "Sources"
        ),
        .testTarget(
            name: "EnvBoxTests",
            dependencies: ["EnvBox"],
            path: "Tests"
        ),
    ]
)
