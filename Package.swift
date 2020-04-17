// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Transmog",
    products: [
        .executable(name: "transmog", targets: ["Transmog"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.1"),
        .package(url: "https://github.com/thii/SwiftHEXColors", from: "1.4.0")
    ],
    targets: [
        .target(
            name: "Transmog",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "SwiftHEXColors"
            ]
        )
    ]
)
