import XCTest

@testable import WrkstrmColor

// TODO: Add HPLuv support
enum JSONResource {
  public static func load(fileName: String) -> Data? {
    let currentFileURL = URL(fileURLWithPath: #file)
    let currentDirectoryURL = currentFileURL.deletingLastPathComponent()

    let fileURL =
      currentDirectoryURL
        .appendingPathComponent("Resources", isDirectory: true)
        .appendingPathComponent(fileName)
        .appendingPathExtension("json")

    return try? Data(contentsOf: fileURL)
  }
}

typealias SnapshotDictionary = [String: [String: [Double]]]

// swiftlint:disable:next convenience_type
enum Snapshot {
  static var hexSamples: [String] = {
    let samples = "0123456789abcdef"

    var hexSamples = [String]()
    samples.forEach { r in
      samples.forEach { g in
        samples.forEach { b in
          hexSamples.append("#\(r)\(r)\(g)\(g)\(b)\(b)")
        }
      }
    }

    return hexSamples
  }()

  static var stable: SnapshotDictionary = {
    guard
      let jsonData = JSONResource.load(fileName: "snapshot-rev4"),
      let jsonResult = try? JSONSerialization.jsonObject(
        with: jsonData,
        options: .fragmentsAllowed) as? SnapshotDictionary
    else {
      fatalError("Snapshot JSON file is missing")
    }
    return jsonResult
  }()

  static var current: SnapshotDictionary = {
    var current: SnapshotDictionary = .init()

    for sample in Snapshot.hexSamples {
      let hex: Hex = .init(sample)

      let rgb: RGB<Double> = hex.toRgb()
      let xyz = rgb.toXyz
      let luv = xyz.toLuv
      let lch = luv.toLch
      let hsluv: HSLuv<Double> = lch.toHSLuv

      current[sample] = [
        "rgb": [rgb.r, rgb.g, rgb.b],
        "xyz": [xyz.x, xyz.y, xyz.z],
        "luv": [luv.l, luv.u, luv.v],
        "lch": [lch.l, lch.c, lch.h],
        "hsluv": [hsluv.h, hsluv.s, hsluv.l],
      ]
    }

    return current
  }()

  static func compare(
    _: SnapshotDictionary,
    block: (
      _ hex: String,
      _ tag: String,
      _ stableTuple: [Double],
      _ currentTuple: [Double],
      _ stableChannel: Double,
      _ currentChannel: Double) -> Void)
  {
    for (hex, stableSamples) in stable {
      guard let currentSamples = current[hex] else {
        fatalError("Current sample is missing at \(hex)")
      }

      tags: for (tag, stableTuple) in stableSamples {
        if tag == "hpluv" {
          continue tags
        }

        guard let currentTuple = currentSamples[tag] else {
          fatalError("Current tuple is missing at \(hex):\(tag)")
        }

        for i in [0...2] {
          guard let stableChannel = stableTuple[i].first,
                let currentChannel = currentTuple[i].first
          else {
            fatalError("Current channel is missing at \(hex):\(tag):\(i)")
          }

          block(hex, tag, stableTuple, currentTuple, stableChannel, currentChannel)
        }
      }
    }
  }
}
