// swift-tools-version:5.9
import PackageDescription

let package = Package(
  name: "WrkstrmColor",
  platforms: [
    .iOS(.v16),
    .macOS(.v13),
  ],
  products: [
    .library(name: "WrkstrmColor", targets: ["WrkstrmColor"]),
  ],
  targets: [
    .target(name: "WrkstrmColor", dependencies: []),
    .testTarget(
      name: "WrkstrmColorTests",
      dependencies: ["WrkstrmColor"],
      resources: [.copy("Resources/snapshot-rev4.json")]),
  ])
