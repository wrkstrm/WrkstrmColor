import Foundation
import Testing

@testable import WrkstrmColor

// TODO: Add HPLuv tests

@Suite
struct HSLuvTests {
  let rgbRangeTolerance = 0.000_000_001
  let snapshotTolerance = 0.000_000_001

  @Test
  func testConversionConsistency() async {
    for hex in await Snapshot.hexSamples {
      let rgb: RGB<Double> = Hex(hex).toRgb()
      let xyz = rgb.toXyz
      let luv = xyz.toLuv
      let lch = luv.toLch
      let hsluv: HSLuv<Double> = lch.toHSLuv

      let toLch = hsluv.toLch
      let toLuv = toLch.toLUV
      let toXyz = toLuv.toXYZ
      let toRgb: RGB<Double> = toXyz.toRGB
      let toHex = toRgb.toHex

      #expect(abs(lch.l - toLch.l) <= rgbRangeTolerance)
      #expect(abs(lch.c - toLch.c) <= rgbRangeTolerance)
      #expect(abs(lch.h - toLch.h) <= rgbRangeTolerance)

      #expect(abs(luv.l - toLuv.l) <= rgbRangeTolerance)
      #expect(abs(luv.u - toLuv.u) <= rgbRangeTolerance)
      #expect(abs(luv.v - toLuv.v) <= rgbRangeTolerance)

      #expect(abs(xyz.x - toXyz.x) <= rgbRangeTolerance)
      #expect(abs(xyz.y - toXyz.y) <= rgbRangeTolerance)
      #expect(abs(xyz.z - toXyz.z) <= rgbRangeTolerance)

      #expect(abs(rgb.r - toRgb.r) <= rgbRangeTolerance)
      #expect(abs(rgb.g - toRgb.g) <= rgbRangeTolerance)
      #expect(abs(rgb.b - toRgb.b) <= rgbRangeTolerance)

      #expect(hex == toHex.string)
    }
  }

  @Test
  func testRgbRangeTolerance() {
    for h in stride(from: 0.0, through: 360, by: 5) {
      for s in stride(from: 0.0, through: 100, by: 5) {
        for l in stride(from: 0.0, through: 100, by: 5) {
          let tRgb = hsluvToRgb(HSLuv(h: h, s: s, l: l))
          let rgb = [tRgb.r, tRgb.g, tRgb.b]

          for channel in rgb {
            #expect(
              channel > -rgbRangeTolerance,
              "HSLuv: \([h, s, l]) -> RGB: \(rgb)",
            )
            #expect(
              channel <= 1 + rgbRangeTolerance,
              "HSLuv: \([h, s, l]) -> RGB: \(rgb)",
            )
          }
        }
      }
    }
  }

  @Test
  func testSnapshot() async {
    await Snapshot.compare(await Snapshot.current) {
      [snapshotTolerance] hex, tag, stableTuple, currentTuple, stableChannel, currentChannel in
      let diff = abs(currentChannel - stableChannel)

      #expect(
        diff < snapshotTolerance,
        """
        Snapshots for \(hex) don't match at \(tag):
        (stable: \(stableTuple), current: \(currentTuple)
        """,
      )
    }
  }
}
