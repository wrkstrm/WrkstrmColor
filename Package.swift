// swift-tools-version:5.9
import PackageDescription

extension SwiftSetting {
  static let profile: SwiftSetting = .unsafeFlags([
    "-Xfrontend",
    "-warn-long-expression-type-checking=6",
  ])
}

let package = Package(
  name: "WrkstrmColor",
  platforms: [
    .iOS(.v16),
    .macOS(.v13),
    .tvOS(.v16),
    .watchOS(.v9),
  ],
  products: [
    .library(name: "WrkstrmColor", targets: ["WrkstrmColor"]),
  ],
  targets: [
    .target(name: "WrkstrmColor", swiftSettings: [.profile]),
    .testTarget(
      name: "WrkstrmColorTests",
      dependencies: ["WrkstrmColor"],
      resources: [.process("Resources")],
      swiftSettings: [.profile]),
  ])
