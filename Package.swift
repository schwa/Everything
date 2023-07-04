// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Everything",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .macCatalyst(.v15),
        .tvOS(.v16),
    ],
    products: [
        .library(name: "Everything", targets: ["Everything"]),
        .library(name: "EverythingHelpers", targets: ["EverythingHelpers"]),
        .library(name: "EverythingUnsafeConformances", targets: ["EverythingUnsafeConformances"]),
    ],
    dependencies: [
        .package(url: "https://github.com/schwa/CoreGraphicsGeometrySupport", from: "0.1.0"),
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Everything",
            dependencies: [
                "EverythingHelpers",
                "CoreGraphicsGeometrySupport",
                .product(name: "Algorithms", package: "swift-algorithms")
            ],
            swiftSettings:
            unsafeFlags()
        ),
        .target(name: "EverythingHelpers"),
        .target(name: "EverythingUnsafeConformances"),
        .testTarget(name: "EverythingTests", dependencies: ["Everything"]),
    ]
)

func unsafeFlags() -> [PackageDescription.SwiftSetting] {
    [
    ]
//    return [
//        .unsafeFlags(["-Xfrontend", "-warn-concurrency", "-Xfrontend", "-enable-actor-data-race-checks"])
//    ]
}
