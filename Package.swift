// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Deluge",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "Deluge", targets: ["Deluge"]),
    ],
    targets: [
        .target(name: "Deluge"),
        .testTarget(name: "DelugeIntegrationTests", dependencies: [.target(name: "Deluge")]),
    ]
)
