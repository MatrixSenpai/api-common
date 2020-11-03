// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "api-common",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "APICommon", targets: ["api-common"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "5.0.0"),
        .package(url: "https://github.com/OAuthSwift/OAuthSwift", from: "2.1.0"),
    ],
    targets: [
        .target(name: "api-common", dependencies: ["RxSwift", "OAuthSwift"]),
        
        .testTarget(name: "api-commonTests", dependencies: ["api-common"]),
    ]
)
