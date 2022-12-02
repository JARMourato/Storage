// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Storage",
    platforms: [.iOS(.v13), .macOS(.v12), .watchOS(.v6), .tvOS(.v13)],
    products: [
        .library(name: "Storage", targets: ["Storage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Square/Valet", from: "4.0.0"),
    ],
    targets: [
        .target(name: "Storage", dependencies: [], path: "Sources/Core"),
        .target(name: "StoragePlus", dependencies: ["Storage", "Valet"], path: "Sources/Storages"),
        .testTarget(name: "StorageTests", dependencies: ["StoragePlus"], path: "Tests"),
    ]
)
