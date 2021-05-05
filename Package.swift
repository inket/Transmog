// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Transmog",
    products: [
        .executable(name: "transmog", targets: ["Transmog"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "0.4.0")),
        .package(url: "https://github.com/thii/SwiftHEXColors", .upToNextMajor(from: "1.4.0")),
        .package(url: "https://github.com/marmelroy/Zip", .upToNextMajor(from: "2.1.0"))
    ],
    targets: [
        .target(
            name: "Transmog",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "SwiftHEXColors",
                "Zip"
            ]
        )
    ]
)
