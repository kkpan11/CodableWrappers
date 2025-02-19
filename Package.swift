// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "CodableWrappers",
    platforms: [.macOS(.v11), .iOS(.v14), .tvOS(.v14), .watchOS(.v7), .macCatalyst(.v14), .visionOS(.v1)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "CodableWrappers",
            targets: ["CodableWrappers"]),
/*
 *Targets used to ease active development
        .library(
            name: "CodableMacros",
            targets: ["CodableMacros"]
        ),
        .executable(
            name: "TestClient",
            targets: ["TestClient"]
        ),
*/
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "13.0.0")),
        .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "7.6.0")),
        // swiftlint is kinda big to pull in and build right now...maybe later
//        .package(url: "https://github.com/realm/SwiftLint.git", .upToNextMajor(from: "0.52.0")),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", "508.0.0"..."600.0.1"),
        // For testing different versions of swift-syntax
//        .package(url: "https://github.com/apple/swift-syntax.git", .upToNextMajor(from: "510.0.0"))

    ],
    targets: [
        .target(
            name: "CodableWrappers",
            dependencies: ["CodableWrapperMacros"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]),
//            plugins: [.plugin(name: "SwiftLintPlugin", package: "SwiftLint")]),

        .testTarget(
            name: "CodableWrappersTests",
            dependencies: ["CodableWrappers", "Quick", "Nimble"]),

        .macro(
            name: "CodableWrapperMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),

/*
 *Targets used to ease active development

        // This is really just one file. Keeping it separate for faster development/testing
        .target(name: "CodableMacros", dependencies: ["CodableWrapperMacros"]),

        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(name: "TestClient", dependencies: ["CodableMacros"]),
*/
        // A test target used to develop the macro implementation.
        .testTarget(
            name: "CodableWrapperMacrosTests",
            dependencies: [
                "CodableWrapperMacros",
                "Quick", "Nimble",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "IntegrationTests",
            dependencies: [
                "CodableWrapperMacros",
                "Quick", "Nimble",
                "CodableWrappers",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ],
    swiftLanguageVersions: [.version("6"), .v5]
)
