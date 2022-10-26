// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "WrkstrmColor",
  platforms: [
    .iOS(.v13),
    .macOS(.v13),
  ],
  // Products define the executables and libraries produced by a package, and make them visible
  // to other packages.
  products: [
    .library(name: "WrkstrmColor", targets: ["WrkstrmColor"]),
  ],
  // Dependencies declare other packages that this package depends on.
  dependencies: [
    // .package(url: /* package url */, from: "1.0.0"),
  ],
  // Targets are the basic building blocks of a package. A target can define a module or a test
  // suite. Targets can depend on other targets in this package, and on products in packages which
  // this package depends on.
  targets: [
    .target(name: "WrkstrmColor", dependencies: []),
    .testTarget(name: "WrkstrmColorTests", dependencies: ["WrkstrmColor"]),
  ])
