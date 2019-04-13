// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

private struct SWXCResultJSON {
    static let name = "SWXCResultJSON"
}

let package = Package(
    name: SWXCResultJSON.name,
    platforms: [
        .macOS(.v10_14),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: SWXCResultJSON.name,
            targets: [SWXCResultJSON.name]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "git@github.com:roman-dzieciol/swift-xcactivitylog.git", from: "1.0.0"),
        .package(url: "git@github.com:roman-dzieciol/swift-xcresult.git", from: "10.2.0-1.2.2+10E125"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: SWXCResultJSON.name,
            dependencies: ["SWXCActivityLog", "SWXCResult"]),
        .testTarget(
            name: SWXCResultJSON.name + "Tests",
            dependencies: [.target(name: SWXCResultJSON.name)]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
