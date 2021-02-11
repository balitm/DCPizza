// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Domain",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Domain",
            type: .static,
            targets: ["Domain"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.1.0")),
        .package(url: "https://github.com/Alamofire/AlamofireImage", .upToNextMajor(from: "4.1.0")),
        .package(name: "Realm", url: "https://github.com/realm/realm-cocoa", from: "10.5.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "CppCart",
            path: "Sources/CppCart"
        ),
        .target(
            name: "CWrapper",
            dependencies: ["CppCart"]
        ),
        .target(
            name: "Domain",
            dependencies: [
                "CWrapper",
                "Alamofire", "AlamofireImage",
                .product(name: "RealmSwift", package: "Realm"),
            ]
        ),
        .testTarget(
            name: "DomainTests",
            dependencies: ["Domain"]),
    ],
    cxxLanguageStandard: .gnucxx14
)
