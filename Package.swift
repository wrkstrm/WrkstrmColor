// swift-tools-version:6.1
import Foundation
import PackageDescription

// MARK: - PackageDescription extensions

Package.Inject.local.dependencies = [
  .package(name: "WrkstrmFoundation", path: "../../universal/WrkstrmFoundation")
]

Package.Inject.remote.dependencies = [
  .package(url: "https://github.com/wrkstrm/WrkstrmFoundation.git", from: "2.0.0")
]

let package = Package(
  name: "WrkstrmColor",
  platforms: [
    .iOS(.v16),
    .macOS(.v13),
    .tvOS(.v16),
    .watchOS(.v9),
  ],
  products: [
    .library(name: "WrkstrmColor", targets: ["WrkstrmColor"])
  ],
  dependencies: Package.Inject.shared.dependencies,
  targets: [
    .target(name: "WrkstrmColor", swiftSettings: Package.Inject.shared.swiftSettings),
    .testTarget(
      name: "WrkstrmColorTests",
      dependencies: ["WrkstrmColor", "WrkstrmFoundation"],
      resources: [.process("Resources")],
      swiftSettings: Package.Inject.shared.swiftSettings,
    ),
  ],
)

// MARK: - Package Service

extension Package {
  @MainActor
  public struct Inject {
    public static let version = "0.0.1"

    public var swiftSettings: [SwiftSetting] = []
    var dependencies: [PackageDescription.Package.Dependency] = []

    public static let shared: Inject = ProcessInfo.useLocalDeps ? .local : .remote

    static var local: Inject = .init(swiftSettings: [.local])
    static var remote: Inject = .init()
  }
}

// MARK: - PackageDescription extensions

extension SwiftSetting {
  public static let local: SwiftSetting = .unsafeFlags([
    "-Xfrontend",
    "-warn-long-expression-type-checking=10",
  ])
}

// MARK: - Foundation extensions

extension ProcessInfo {
  public static var useLocalDeps: Bool {
    ProcessInfo.processInfo.environment["SPM_USE_LOCAL_DEPS"] == "true"
  }
}

// PACKAGE_SERVICE_END_V1
