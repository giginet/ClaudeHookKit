// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ClaudeHookKit",
  platforms: [
    .macOS(.v14)
  ],
  products: [
    .library(
      name: "ClaudeHookKit",
      targets: ["ClaudeHookKit"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-log.git", exact: "1.8.0")
  ],
  targets: [
    .target(
      name: "ClaudeHookKit",
      dependencies: [
        .product(name: "Logging", package: "swift-log")
      ]
    ),
    .testTarget(
      name: "ClaudeHookKitTests",
      dependencies: ["ClaudeHookKit"]
    ),
  ]
)
