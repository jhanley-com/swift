// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "gist-list",
    products: [
        .executable(name: "gist-list", targets: ["gist-list"])
    ],
    dependencies: [
    ],
    targets: [
        .executableTarget(
            name: "gist-list",
            dependencies: [
            ],
            path: "./src")
    ]
)
