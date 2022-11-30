// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "auth-device",
    products: [
        .executable(name: "auth-device", targets: ["auth-device"])
    ],
    dependencies: [
    ],
    targets: [
        .executableTarget(
            name: "auth-device",
            dependencies: [
            ],
            path: "./src")
    ]
)
