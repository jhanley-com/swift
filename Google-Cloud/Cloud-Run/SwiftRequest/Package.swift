// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "SwiftRequest",
    dependencies: [
        .package(url: "https://github.com/httpswift/swifter.git", .upToNextMajor(from: "1.5.0"))
    ],
    targets: [
        .target(
        name: "SwiftRequest",
        dependencies: ["Swifter"],
        path: "./src")
    ]
)
