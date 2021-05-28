// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "NeumorphicUI",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "NeumorphicUI", targets: ["NeumorphicUI"])
    ],
    targets: [
        .target(name: "NeumorphicUI")
    ]
)
