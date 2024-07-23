// swift-tools-version:5.10
import Foundation
import PackageDescription

// MARK: - Foundation extensions

extension ProcessInfo {
  static var useLocalDeps: Bool {
    ProcessInfo.processInfo.environment["SPM_USE_LOCAL_DEPS"] == "true"
  }
}

// MARK: - PackageDescription extensions

extension SwiftSetting {
  static let localSwiftSettings: SwiftSetting = .unsafeFlags([
    "-Xfrontend",
    "-warn-long-expression-type-checking=10",
  ])
}

// MARK: - PackageDescription extensions

extension [PackageDescription.Package.Dependency] {
  static let local: [PackageDescription.Package.Dependency] =
    [
      .package(name: "WrkstrmFoundation", path: "../WrkstrmFoundation")
    ]

  static let remote: [PackageDescription.Package.Dependency] =
    [
      .package(url: "https://github.com/wrkstrm/WrkstrmFoundation.git", from: "0.4.0")
    ]
}

// MARK: - Configuration Service

struct ConfigurationService {
  let swiftSettings: [SwiftSetting]
  let dependencies: [PackageDescription.Package.Dependency]

  private static let local: ConfigurationService = .init(
    swiftSettings: [.localSwiftSettings],
    dependencies: .local
  )

  private static let remote: ConfigurationService = .init(swiftSettings: [], dependencies: .remote)

  static let shared: ConfigurationService = ProcessInfo.useLocalDeps ? .local : .remote
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
    .library(name: "WrkstrmColor", targets: ["WrkstrmColor"])
  ],
  dependencies: ConfigurationService.shared.dependencies,
  targets: [
    .target(name: "WrkstrmColor", swiftSettings: ConfigurationService.shared.swiftSettings),
    .testTarget(
      name: "WrkstrmColorTests",
      dependencies: ["WrkstrmColor", "WrkstrmFoundation"],
      resources: [.process("Resources")],
      swiftSettings: ConfigurationService.shared.swiftSettings
    ),
  ]
)
