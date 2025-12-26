// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ClaudeHookKit",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "ClaudeHookKit",
            targets: ["ClaudeHookKit"]
        ),
    ],
    targets: [
        .target(
            name: "ClaudeHookKit"
        ),
        .testTarget(
            name: "ClaudeHookKitTests",
            dependencies: ["ClaudeHookKit"]
        ),
    ]
)
