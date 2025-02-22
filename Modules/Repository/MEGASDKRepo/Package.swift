// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "MEGASDKRepo",
    platforms: [
        .macOS(.v10_15), .iOS(.v14)
    ],
    products: [
        .library(
            name: "MEGASDKRepo",
            targets: ["MEGASDKRepo"]),
        .library(
            name: "MEGASDKRepoMock",
            targets: ["MEGASDKRepoMock"])
    ],
    dependencies: [
        .package(path: "../../Domain/MEGADomain"),
        .package(path: "../../Domain/MEGAAnalyticsDomain"),
        .package(path: "../../MEGASdk"),
        .package(path: "../../Infrastracture/MEGATest"),
        .package(url: "https://github.com/meganz/SAMKeychain.git", from: "2.0.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "9.0.0"),
        .package(path: "../../MEGARepo")
    ],
    targets: [
        .target(
            name: "MEGASDKRepo",
            dependencies: [
                "MEGAAnalyticsDomain",
                "MEGADomain",
                "MEGASdk",
                "SAMKeychain",
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAppDistribution-Beta", package: "firebase-ios-sdk"),
                "MEGARepo"
            ],
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")]),
        .target(
            name: "MEGASDKRepoMock",
            dependencies: ["MEGASDKRepo"],
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")]
        ),
        .testTarget(
            name: "MEGASDKRepoTests",
            dependencies: [
                "MEGASDKRepo",
                "MEGASDKRepoMock",
                .product(name: "MEGADomainMock", package: "MEGADomain"),
                "MEGATest"
            ],
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")]
        )
    ]
)
