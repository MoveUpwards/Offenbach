// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Offenbach",
    platforms: [
        .iOS(.v10),
    ],
    products: [
        .library(
            name: "Offenbach",
            targets: ["Offenbach"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .exact("5.0.0-beta.7"))
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
