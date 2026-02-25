// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "WakeUpCall",
    platforms: [
        .iOS(.v15),
        .macOS(.v13)
    ],
    products: [
        .library(name: "WakeUpDomain", targets: ["WakeUpDomain"]),
        .library(name: "WakeUpServices", targets: ["WakeUpServices"]),
        .library(name: "WakeUpFeatures", targets: ["WakeUpFeatures"]),
        .library(name: "WakeUpUI", targets: ["WakeUpUI"]),
        .executable(name: "WakeUpPrototypeCLI", targets: ["WakeUpPrototypeCLI"]),
        .executable(name: "WakeUpChecks", targets: ["WakeUpChecks"])
    ],
    targets: [
        .target(name: "WakeUpDomain"),
        .target(
            name: "WakeUpServices",
            dependencies: ["WakeUpDomain"]
        ),
        .target(
            name: "WakeUpFeatures",
            dependencies: ["WakeUpDomain", "WakeUpServices"]
        ),
        .target(
            name: "WakeUpUI",
            dependencies: ["WakeUpDomain", "WakeUpFeatures"]
        ),
        .executableTarget(
            name: "WakeUpPrototypeCLI",
            dependencies: ["WakeUpDomain", "WakeUpServices", "WakeUpFeatures"]
        ),
        .executableTarget(
            name: "WakeUpChecks",
            dependencies: ["WakeUpDomain", "WakeUpServices", "WakeUpFeatures"]
        ),
        .testTarget(
            name: "WakeUpDomainTests",
            dependencies: ["WakeUpDomain"]
        ),
        .testTarget(
            name: "WakeUpFeaturesTests",
            dependencies: ["WakeUpDomain", "WakeUpServices", "WakeUpFeatures"]
        ),
        .testTarget(
            name: "WakeUpIntegrationTests",
            dependencies: ["WakeUpDomain", "WakeUpServices", "WakeUpFeatures"]
        )
    ]
)
