// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-kernel-primitives",
    products: [
        .library(
            name: "Kernel Primitives",
            targets: ["Kernel Primitives"]
        ),
        .library(
            name: "Kernel Primitives Test Support",
            targets: ["Kernel Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-standards/swift-standards.git", from: "0.29.0")
    ],
    targets: [
        .target(
            name: "CLinuxShim",
            dependencies: []
        ),
        .target(
            name: "CDarwinShim",
            dependencies: []
        ),
        .target(
            name: "CPosixShim",
            dependencies: []
        ),
        .target(
            name: "Kernel Primitives",
            dependencies: [
                .product(name: "Binary", package: "swift-standards"),
                .target(name: "CDarwinShim", condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS])),
                .target(name: "CLinuxShim", condition: .when(platforms: [.linux])),
                .target(name: "CPosixShim", condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .linux])),
            ]
        ),
        .target(
            name: "Kernel Primitives Test Support",
            dependencies: [
                "Kernel Primitives"
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Kernel Primitives Tests",
            dependencies: [
                "Kernel Primitives",
                "Kernel Primitives Test Support",
                .product(name: "StandardsTestSupport", package: "swift-standards")
            ],
            path: "Tests/Kernel Primitives Tests"
        ),
    ]
)

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let settings: [SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility")
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + settings
}
