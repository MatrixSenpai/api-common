// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "core",
    products: [
        .library(name: "APICommon", targets: ["core"]),
        .library(name: "RxAPICommon", targets: ["core", "rx_exts"])
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .exact("6.1.0"))
    ],
    targets: [
        .target(name: "core", dependencies: []),
        .target(name: "rx_exts", dependencies: ["RxSwift"]),
        
        .testTarget(name: "coreTests", dependencies: ["core"]),
//        .testTarget(name: "rxCoreTests", dependencies: ["rx_exts", "RxSwift"])
    ]
)
