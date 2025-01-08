// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "Deluge",
    platforms: [
        .iOS(.v18),
        .tvOS(.v18),
        .macOS(.v15),
    ],
    products: [
        .library(name: "Deluge", targets: ["Deluge"]),
    ],
    targets: [
        .target(name: "Deluge"),
        .testTarget(name: "DelugeIntegrationTests", dependencies: [.target(name: "Deluge")]),
    ]
)
