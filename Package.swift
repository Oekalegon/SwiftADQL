// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftADQL",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftADQL",
            targets: ["SwiftADQL"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-parsing", from: "0.7.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwiftADQL",
            dependencies: [.product(name: "Parsing", package: "swift-parsing")]
        ),
        .testTarget(
            name: "SwiftADQLTests",
            dependencies: ["SwiftADQL"],
            resources: [
                .copy("Resources"),
            ]
        ),
    ]
)
