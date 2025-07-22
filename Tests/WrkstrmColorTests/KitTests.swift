import Foundation
import XCTest

@testable import WrkstrmColor

#if canImport(UIKit)
  import CoreGraphics

  class UIKitTests: XCTestCase {
    let rgbRangeTolerance: CGFloat = 0.000_000_000_01

    func testUIColorRGBRangeTolerance() {
      for h in stride(from: 0, through: 360, by: 5) {
        for s in stride(from: 0, through: 100, by: 5) {
          for l in stride(from: 0, through: 100, by: 5) {
            let color: UIColor = .init(
              hsluv: .init(
                h: CGFloat(h),
                s: CGFloat(s),
                l: CGFloat(l),
              ), alpha: 1.0,
            )

            XCTAssertNotNil(color)

            let tRgb = color.rgbaComponents().rgb
            let rgb = [tRgb.r, tRgb.g, tRgb.b]

            for channel in rgb {
              XCTAssertGreaterThan(
                channel,
                -rgbRangeTolerance,
                "HSLuv: \([h, s, l]) -> RGB: \(rgb)",
              )
              XCTAssertLessThanOrEqual(
                channel,
                1 + rgbRangeTolerance,
                "HSLuv: \([h, s, l]) -> RGB: \(rgb)",
              )
            }
          }
        }
      }
    }
  }

#elseif os(macOS)

  class AppKitTests: XCTestCase {
    let rgbRangeTolerance = 0.000_000_000_01

    func testNSColorRGBRangeTolerance() {
      for h in stride(from: CGFloat(0.0), through: 360, by: 5) {
        for s in stride(from: CGFloat(0.0), through: 100, by: 5) {
          for l in stride(from: CGFloat(0.0), through: 100, by: 5) {
            let color: NSColor = .init(hue: h, saturation: s, lightness: l, alpha: 1.0)

            XCTAssertNotNil(color)

            let tRGBA = color.rgbaComponents()
            let rgb = [tRGBA.rgb.r, tRGBA.rgb.g, tRGBA.rgb.b]

            for channel in rgb {
              XCTAssertGreaterThan(
                channel,
                CGFloat(-rgbRangeTolerance),
                "HSLuv: \([h, s, l]) -> RGB: \(rgb)",
              )
              XCTAssertLessThanOrEqual(
                channel,
                CGFloat(1 + rgbRangeTolerance),
                "HSLuv: \([h, s, l]) -> RGB: \(rgb)",
              )
            }
          }
        }
      }
    }
  }

#endif
