import CoreGraphics
import Foundation

extension Palette {

  // swiftlint:disable:next function_body_length
  public static func rgb(
    for gradient: Gradient,
    index: Int,
    count: Int, reversed: Bool = false
  ) -> RGB<Double> {
    var newIndex = Double(index)
    var newCount = Double(count)

    if reversed {
      newIndex = newCount - newIndex
    }

    var starting: (red: Double, green: Double, blue: Double)!
    var ending: (red: Double, green: Double, blue: Double)!

    var cutoff: Double = 0
    switch gradient {
      case .green:
        starting = (red: 25, green: 190, blue: 25)
        let (sR, sG, sB) = starting
        cutoff = 5
        ending = (
          red: sR + cutoff * 10,
          green: sG + cutoff * 10,
          blue: sB + cutoff * 10
        )

      case .blue:
        starting = (red: 45, green: 100, blue: 215)
        let (sR, sG, sB) = starting
        cutoff = 6
        ending = (
          red: sR + cutoff * 12,
          green: sG + cutoff * 12,
          blue: sB + cutoff * 10
        )

      case .red:
        starting = (red: 215, green: 25, blue: 25)
        let (sR, sG, sB) = starting
        cutoff = 4
        ending = (
          red: sR + cutoff * 10,
          green: sG + cutoff * 20,
          blue: sB + cutoff * 10
        )

      case .black:
        starting = (red: 65, green: 65, blue: 65)
        let (sR, sG, sB) = starting
        cutoff = 7
        ending = (
          red: sR + cutoff * 8,
          green: sG + cutoff * 8,
          blue: sB + cutoff * 8
        )

      default:
        starting = (red: 200, green: 200, blue: 200)
        let (sR, sG, sB) = starting
        cutoff = 6
        ending = (
          red: sR + cutoff * 6,
          green: sG + cutoff * 6,
          blue: sB + cutoff * 6
        )
    }

    var delta = 1.0 / cutoff
    if newCount > cutoff {
      delta = 1.0 / newCount
    } else {
      newCount = cutoff
    }

    assert(newIndex <= newCount)

    let s = delta * (newCount - newIndex)
    let e = delta * newIndex

    let (sR, sG, sB) = starting
    let (eR, eG, eB) = ending

    let red = sR * s + eR * e
    let green = sG * s + eG * e
    let blue = sB * s + eB * e
    return RGB(r: red, g: green, b: blue)
  }
}

#if canImport(SwiftUI)
import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Palette {

  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  static func hsluv(
    for gradient: Gradient,
    index: Int,
    count: Int,
    reversed: Bool = false
  ) -> Color {
    let color: HSLuv<CGFloat> =
      hsluvGradient(for: gradient, index: index, count: count, reversed: reversed)
    return Color(hsluv: color, opacity: 1)
  }

  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  static func color(
    for wrkstrm: Wrkstrm,
    index: Int,
    count: Int,
    reversed: Bool = false
  ) -> Color {
    color(
      for: Gradient(rawValue: wrkstrm.rawValue)!,  // swiftlint:disable:this force_unwrapping
      index: index,
      count: count,
      reversed: reversed)
  }

  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  static func color(
    for gradient: Gradient,
    index: Int,
    count: Int,
    reversed: Bool = false
  ) -> Color {
    let color = rgb(for: gradient, index: index, count: count, reversed: reversed)
    return Color(
      red: color.r / 255.0,
      green: color.g / 255.0,
      blue: color.b / 255.0,
      opacity: 1.0)
  }
}

#endif  // canImport(SwiftUI)

#if canImport(UIKit)
import UIKit

extension Palette {

  public static func hsluv(
    for gradient: Gradient,
    index: Int,
    count: Int,
    reversed: Bool = false
  ) -> UIColor {
    let color: HSLuv<CGFloat> =
      hsluvGradient(for: gradient, index: index, count: count, reversed: reversed)
    return UIColor(hsluv: color, alpha: 1)
  }

  public static func color(
    for wrkstrm: Wrkstrm,
    index: Int,
    count: Int,
    reversed: Bool = false
  ) -> UIColor {
    color(
      for: Gradient(rawValue: wrkstrm.rawValue)!,  // swiftlint:disable:this force_unwrapping
      index: index,
      count: count,
      reversed: reversed)
  }

  public static func color(
    for gradient: Gradient,
    index: Int,
    count: Int,
    reversed: Bool = false
  ) -> UIColor {
    let color = rgb(for: gradient, index: index, count: count, reversed: reversed)
    return UIColor(
      red: CGFloat(color.r / 255.0),
      green: CGFloat(color.g / 255.0),
      blue: CGFloat(color.b / 255.0),
      alpha: 1.0)
  }
}

#endif

#if os(OSX)
import Cocoa

extension Palette {

  static func hsluv(
    for gradient: Gradient,
    index: Int,
    count: Int,
    reversed: Bool = false
  ) -> NSColor {
    let color: HSLuv<CGFloat> = hsluvGradient(
      for: gradient, index: index, count: count, reversed: reversed)
    return NSColor(hsluv: color, alpha: 1)
  }

  static func color(
    for wrkstrm: Wrkstrm,
    index: Int,
    count: Int,
    reversed: Bool = false
  ) -> NSColor {
    color(
      for: Gradient(rawValue: wrkstrm.rawValue)!,  // swiftlint:disable:this force_unwrapping
      index: index,
      count: count,
      reversed: reversed)
  }

  static func color(
    for gradient: Gradient,
    index: Int,
    count: Int,
    reversed: Bool = false
  ) -> NSColor {
    let color = rgb(for: gradient, index: index, count: count, reversed: reversed)
    return NSColor(
      red: CGFloat(color.r / 255.0),
      green: CGFloat(color.g / 255.0),
      blue: CGFloat(color.b / 255.0),
      alpha: 1.0)
  }
}

#endif
