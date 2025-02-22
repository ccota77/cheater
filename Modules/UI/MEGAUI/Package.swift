// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "MEGAUI",
    platforms: [
        .macOS(.v10_15), .iOS(.v14)
    ],
    products: [
        .library(
            name: "MEGAUI",
            targets: ["MEGAUI"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "MEGAUI",
            dependencies: [],
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")]),
        .testTarget(
            name: "MEGAUITests",
            dependencies: ["MEGAUI"],
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")])
    ]
)
