// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Offenbach",
    products: [
        .library(
            name: "Offenbach",
            targets: ["Offenbach"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.0.0-beta.7")
    ],
    targets: [
        .target(
            name: "Offenbach",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "OffenbachTests",
            dependencies: ["Offenbach"],
            path: "Tests"
        ),
    ]
)
