// swift-tools-version: 6.1

import PackageDescription

var package = Package(
    name: "NimbusMobileFuseKit",
    platforms: [.iOS(.v13)],
    products: [
        .library(
           name: "NimbusMobileFuseKit",
           targets: ["NimbusMobileFuseKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/mobilefuse/mobilefuse-ios-sdk-spm", from: "1.10.0"),
    ],
    targets: [
        .target(
            name: "NimbusMobileFuseKit",
            dependencies: [
                .product(name: "NimbusKit", package: "nimbus-ios-sdk"),
                .product(name: "MobileFuseSDK", package: "mobilefuse-ios-sdk-spm"),
            ]
        ),
        .testTarget(
            name: "NimbusMobileFuseKitTests",
            dependencies: ["NimbusMobileFuseKit"],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
    ]
)

package.dependencies.append(.package(url: "https://github.com/adsbynimbus/nimbus-ios-sdk", from: "3.0.0"))
