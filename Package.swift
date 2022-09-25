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
    ],
    targets: [
        .target(
            name: "Everything",
            dependencies: ["EverythingHelpers"],
            swiftSettings:
                unsafeFlags()
            ),
        .target(name: "EverythingHelpers"),
        .testTarget(name: "EverythingTests", dependencies: ["Everything"]),
    ]
)

func unsafeFlags() -> [PackageDescription.SwiftSetting] {
    return [
    ]
//    return [
//        .unsafeFlags(["-Xfrontend", "-warn-concurrency", "-Xfrontend", "-enable-actor-data-race-checks"])
//    ]
}
