// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Manounou",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Manounou",
            targets: ["Manounou"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "Manounou",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift")
            ]
        )
    ]
)