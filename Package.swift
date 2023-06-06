// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StronglyTypedID",
    platforms: [
        .iOS(.v11),
        .macCatalyst(.v13),
        .macOS(.v10_13),
        .tvOS(.v11),
        .watchOS(.v4)
    ],
    products: [
        .library(
            name: "StronglyTypedID",
            targets: ["StronglyTypedID"]
        )
    ],
    targets: [
        .target(
            name: "StronglyTypedID",
            dependencies: []
        ),
        .testTarget(
            name: "StronglyTypedIDTests",
            dependencies: ["StronglyTypedID"]
        )
    ]
)
