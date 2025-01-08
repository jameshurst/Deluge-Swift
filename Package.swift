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
    dependencies: [
        .package(url: "https://github.com/NinjaLikesCheez/swift-api-client.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Deluge",
            dependencies: [
                .product(name: "APIClient", package: "swift-api-client"),
            ]
        ),
        .testTarget(name: "DelugeIntegrationTests", dependencies: [.target(name: "Deluge")]),
    ]
)
