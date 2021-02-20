// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "core",
    products: [
        .library(name: "APICommon", targets: ["APICommon"]),
        .library(name: "RxAPICommon", targets: ["APICommon", "rx_exts"])
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .exact("6.1.0"))
    ],
    targets: [
        .target(name: "APICommon", dependencies: [], path: "Sources/core"),
        .target(name: "rx_exts", dependencies: ["APICommon", "RxSwift"]),
        
        .testTarget(name: "coreTests", dependencies: ["APICommon"]),
//        .testTarget(name: "rxCoreTests", dependencies: ["rx_exts", "RxSwift"])
    ]
)
