// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ManounouSwiftUI",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "ManounouSwiftUI",
            targets: ["ManounouSwiftUI"]
        ),
    ],
    dependencies: [
        // Supabase Swift SDK
        .package(
            url: "https://github.com/supabase/supabase-swift.git",
            from: "2.5.1"
        ),
        // Async Image Loading
        .package(
            url: "https://github.com/kean/Nuke.git",
            from: "12.0.0"
        ),
        // Date Formatting
        .package(
            url: "https://github.com/malcommac/SwiftDate.git",
            from: "7.0.0"
        )
    ],
    targets: [
        .target(
            name: "ManounouSwiftUI",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
                .product(name: "NukeUI", package: "Nuke"),
                .product(name: "SwiftDate", package: "SwiftDate")
            ]
        ),
        .testTarget(
            name: "ManounouSwiftUITests",
            dependencies: ["ManounouSwiftUI"]
        ),
    ]
)