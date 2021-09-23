// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Saffron",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
    ],
    products: [
        .library(name: "Saffron", targets: ["Saffron"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "Saffron", dependencies: []),
        .testTarget(name: "SaffronTests", dependencies: ["Saffron"],
            resources: [.copy("Resources")]),
    ]
)
