// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Storage",
    platforms: [.iOS(.v13), .macOS(.v12), .watchOS(.v6), .tvOS(.v13)],
    products: [
        .library(name: "Storage", targets: ["Storage"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "Storage", dependencies: [], path: "Sources"),
        .testTarget(name: "StorageTests", dependencies: ["Storage"], path: "Tests"),
    ]
)
