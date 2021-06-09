// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Graphics",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(name: "Graphics", targets: ["Graphics"])
    ],
    targets: [
        .target(name: "Graphics")
    ]
)
