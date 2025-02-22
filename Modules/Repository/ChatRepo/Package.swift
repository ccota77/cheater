// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "ChatRepo",
    platforms: [
        .macOS(.v10_15), .iOS(.v14)
    ],
    products: [
        .library(
            name: "ChatRepo",
            targets: ["ChatRepo"]
        )
    ],
    dependencies: [
        .package(path: "../../Domain/MEGADomain"),
        .package(path: "../../MEGAChatSdk"),
        .package(path: "../../MEGASDKRepo")
    ],
    targets: [
        .target(
            name: "ChatRepo",
            dependencies: [
                "MEGADomain",
                "MEGAChatSdk",
                "MEGASDKRepo"
            ],
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")]
        )
    ]
)
