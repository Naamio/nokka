// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Nokka",
    products: [
        .library(
            name: "Nokka",
            targets: [
                "Nokka"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", .upToNextMinor(from: "1.7.0")),
        .package(url: "https://github.com/IBM-Swift/Kitura.git", from: "2.0.0"),
        .package(url: "https://github.com/nvzqz/RandomKit.git", from: "5.0.0"),
        .package(url: "https://github.com/IBM-Swift/SwiftyRequest.git", .upToNextMajor(from: "0.0.0"))
    ],
    targets: [
        .target(
            name: "Nokka",
            dependencies: ["HeliumLogger", "Kitura", "RandomKit", "SwiftyRequest"]
        ),
        .testTarget(
            name: "NokkaTests",
            dependencies: []
        )
    ]
)
