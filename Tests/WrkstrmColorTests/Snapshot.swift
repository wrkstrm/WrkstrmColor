import XCTest

@testable import WrkstrmColor

// TODO: Add HPLuv support

typealias SnapshotDictionary = [String: [String: [Double]]]

// swiftlint:disable:next convenience_type
class Snapshot {

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
    let testBundle = Bundle(for: Snapshot.self)
    guard
      let resourceBundlePath = testBundle.paths(forResourcesOfType: "bundle", inDirectory: nil)
      .first(where: { $0.contains("Resources") }),
      let resourceBunble = Bundle(path: resourceBundlePath),
      let jsonURL = resourceBunble.url(forResource: "snapshot-rev4", withExtension: "json"),
      let jsonData = try? Data(contentsOf: jsonURL, options: .mappedIfSafe),
      let jsonResult = try? JSONSerialization.jsonObject(
        with: jsonData,
        options: .topLevelDictionaryAssumed) as? SnapshotDictionary
    else {
      fatalError("Snapshot JSON file is missing")
    }
    return jsonResult
  }()

  static var current: SnapshotDictionary = {
    var current = SnapshotDictionary()

    for sample in Snapshot.hexSamples {
      let hex = Hex(sample)

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
