// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "indexify",
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "4.0.0"),
        .package(url: "https://github.com/kylef/Commander.git", from: "0.8.0"),
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "10.0.0"))
    ],
    targets: [
        .target(
            name: "indexify",
            dependencies: ["indexify_core", "Commander"]
        ),
        .target(
            name: "indexify_core",
            dependencies: ["Alamofire", "Moya"]
        )
    ]
)
