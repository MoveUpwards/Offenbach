// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Offenbach",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_12)
    ],
    products: [
        .library(
            name: "Offenbach",
            targets: ["Offenbach"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.0.0"))
    ],
    targets: [
        .target(
            name: "Offenbach",
            dependencies: ["Alamofire"],
            path: "Sources"
        ),
        .testTarget(
            name: "OffenbachTests",
            dependencies: ["Offenbach"],
            path: "Tests"
        ),
    ]
)
