// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Domain",
    platforms: [.iOS(.v10)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Domain",
            targets: ["Domain"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "4.9.1")),
        .package(url: "https://github.com/Alamofire/AlamofireImage", .upToNextMajor(from: "3.6.0")),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "5.0.0"),
        .package(name: "Realm", url: "https://github.com/realm/realm-cocoa", from: "4.4.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Domain",
            dependencies: [
                "Alamofire", "AlamofireImage",
                "RxSwift",
                .product(name: "RealmSwift", package: "Realm"),
            ]
        ),
        .testTarget(
            name: "DomainTests",
            dependencies: ["Domain"]),
    ]
)
