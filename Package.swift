// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Metaleon",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
    ],
    products: [
        .library(
            name: "Metaleon",
            targets: ["Metaleon"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Metaleon",
            dependencies: [],
            exclude: [],
            resources: [
                .process("Filters/**/*.matal")
            ],
            publicHeadersPath: "."
        )
    ],
    swiftLanguageVersions: [.v5]
)
