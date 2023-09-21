// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "Everything",
    platforms: [
        .iOS(.v15),
        .macOS(.v14),
        .macCatalyst(.v15),
        .tvOS(.v16),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "Everything", targets: ["Everything"]),
        .library(name: "EverythingHelpers", targets: ["EverythingHelpers"]),
        .library(name: "EverythingUnsafeConformances", targets: ["EverythingUnsafeConformances"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/schwa/SwiftGraphics", branch: "jwight/develop"),
    ],
    targets: [
        .target(
            name: "Everything",
            dependencies: [
                "EverythingHelpers",
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Geometry", package: "SwiftGraphics"),
                .product(name: "CoreGraphicsSupport", package: "SwiftGraphics"),
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
