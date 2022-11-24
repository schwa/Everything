// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Everything",
    platforms: [
        .iOS("15.0"),
        .macOS("12.0"),
        .macCatalyst("15.0"),
    ],
    products: [
        .library(name: "Everything", targets: ["Everything"]),
        .library(name: "EverythingHelpers", targets: ["EverythingHelpers"]),
    ],
    dependencies: [
        .package(url: "https://github.com/schwa/CoreGraphicsGeometrySupport", branch: "main"),
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
