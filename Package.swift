// swift-tools-version: 5.9
import PackageDescription
let package = Package(
    name: "BallapsRules",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [.library(name: "BallapsRules", targets: ["BallapsRules"])],
    targets: [
        .target(name: "BallapsRules", path: "BALLAPS", exclude: ["BackgroundMusic.m4a", "Assets.xcassets", "Info.plist", "BALLAPSApp.swift", "ContentView.swift", "UpgradesView.swift", "ShopView.swift", "AudioController.swift"], sources: ["GameRules.swift", "GameState.swift"]),
        .testTarget(name: "BallapsRulesTests", dependencies: ["BallapsRules"], path: "Tests")
    ]
)
