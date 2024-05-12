// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "Everything",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .macCatalyst(.v17),
        .tvOS(.v17),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "Everything", targets: ["Everything"]),
        .library(name: "EverythingHelpers", targets: ["EverythingHelpers"]),
        .library(name: "EverythingUnsafeConformances", targets: ["EverythingUnsafeConformances"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "Everything",
            dependencies: [
                "EverythingHelpers",
                .product(name: "Algorithms", package: "swift-algorithms"),

            ]
        ),
        .target(name: "EverythingHelpers"),
        .target(name: "EverythingUnsafeConformances"),
        .testTarget(name: "EverythingTests", dependencies: ["Everything"]),
    ]
)
