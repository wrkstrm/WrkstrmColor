// swift-tools-version:5.8
import PackageDescription

let package = Package(
  name: "WrkstrmColor",
  platforms: [
    .iOS(.v15),
    .macOS(.v12),
  ],
  products: [
    .library(name: "WrkstrmColor", targets: ["WrkstrmColor"]),
  ],
  dependencies: [
    // .package(url: /* package url */, from: "1.0.0"),
  ],
  targets: [
    .target(name: "WrkstrmColor", dependencies: []),
    .testTarget(
      name: "WrkstrmColorTests",
      dependencies: ["WrkstrmColor"],
      resources: [.copy("Resources/snapshot-rev4.json")]),
  ])
