load("@build_bazel_rules_apple//apple:versioning.bzl", "apple_bundle_version")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_application",)
load("@build_bazel_rules_apple//apple:ios.bzl", "ios_application")
load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

licenses(["notice"])

swift_library(
    name = "swift-ios-library",
    module_name = "HSLuv",
    visibility = ["//visibility:public"],
    srcs = glob(["Source/*.swift","Source/iOS/*.swift"])
)

swift_library(
    name = "ios-tests",
    srcs = glob(["Tests/*.swift",
                 "Tests/iOS/*.swift"]),
    deps = [":swift-ios-library"],
)

ios_unit_test(
    name = "ios-unit-tests",
    infoplists = [":Tests/Info.plist"],
    minimum_os_version = "10.0",
    data = [":Tests/Assets/snapshot-rev4.json"],
    deps = [":ios-tests"],
)

ios_application(
    name = "ios-app",
    bundle_id = "com.wrkstrm.ios.app.hsluv",
    families = ["iphone"],
    minimum_os_version = "10.0",
    infoplists = [":Examples/iOS/Info.plist"],
    visibility = ["//visibility:public"],
    deps = [":swift-ios-library"],
)

swift_library(
    name = "swift-macos-library",
    module_name = "HSLuvMac",
    visibility = ["//visibility:public"],
    srcs = glob(["Source/*.swift","Source/macOS/*.swift"])
)

swift_library(
    name = "macos-examples",
    srcs = glob(["Examples/macOS/Source/*.swift"]),
    data = glob(["Examples/macOS/Resources/**"]),
    deps = [":swift-macos-library"],
)

apple_bundle_version(
    name = "macos-example-version",
    build_version = "1.0",
)

macos_application(
    name = "macos-app",
    bundle_id = "com.wrkstrm.macos.app.hsluv",
    infoplists = [":Examples/macOS/Resources/Info.plist"],
    minimum_os_version = "10.14",
    version = ":macos-example-version",
    deps = [":macos-examples"],
)
