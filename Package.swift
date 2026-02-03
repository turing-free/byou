// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "byou",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "byou",
            targets: ["byou"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "byou",
            dependencies: [],
            exclude: [
                "Info.plist"
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
