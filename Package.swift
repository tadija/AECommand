// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "ae-command-example",
    products: [
        .library(
            name: "CommandExample",
            targets: ["CommandExample"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/tadija/AETool.git", from: "0.1.0"
        ),
    ],
    targets: [
        .target(
            name: "CommandExample",
            dependencies: ["AETool"])
        ,
        .testTarget(
            name: "CommandExampleTests",
            dependencies: ["CommandExample"]
        ),
    ]
)
