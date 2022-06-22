#if canImport(SwiftUI)
import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Color {

  /// Initializes and returns a Color struct using the specified opacity and HSLuv color space
  /// component values.
  ///
  /// - parameter hue: Double
  /// - parameter saturation: Double
  /// - parameter lightness: Double
  /// - parameter opacity: Double
  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  public init(hue: Double, saturation: Double, lightness: Double, opacity: Double) {
    let rgb = hsluvToRgb(HSLuv(h: hue, s: saturation, l: lightness))
    self.init(red: rgb.r, green: rgb.g, blue: rgb.b, opacity: opacity)
  }

  /// Initializes and returns a Color struct using the specified opacity and HSLuv color space
  /// component values.
  ///
  /// - parameter hsluv: HSLuv
  /// - parameter opacity: Double
  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  public init<Value: BinaryFloatingPoint>(hsluv: HSLuv<Value>, opacity: Double) {
    let rgb = hsluvToRgb(hsluv)
    self.init(red: Double(rgb.r), green: Double(rgb.g), blue: Double(rgb.b), opacity: opacity)
  }

  /// Initializes and returns a color object using the specified opacity and HPLuv color space
  /// component values.
  ///
  /// - parameter hpluv: HPLuv
  /// - parameter opacity: Double
  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  public init<Value: BinaryFloatingPoint>(hpluv: HPLuv<Value>, opacity: Double) {
    let rgb = hpluvToRgb(hpluv)
    self.init(
      red: Double(rgb.r),
      green: Double(rgb.g),
      blue: Double(rgb.b),
      opacity: opacity)
  }
}
#endif

#if canImport(UIKit)
import UIKit

extension UIColor {
  /// Initializes and returns a UIColor object using the specified opacity and HSLuv color space
  /// component values.
  ///
  /// - parameter hue: CGFloat
  /// - parameter saturation: CGFloat
  /// - parameter lightness: CGFloat
  /// - parameter alpha: CGFloat
  public convenience init(hue: CGFloat, saturation: CGFloat, lightness: CGFloat, alpha: CGFloat) {
    let rgb = hsluvToRgb(HSLuv(h: hue, s: saturation, l: lightness))
    self.init(red: rgb.r, green: rgb.g, blue: rgb.b, alpha: alpha)
  }

  /// Initializes and returns a UIColor object using the specified opacity and HSLuv color space
  /// component values.
  ///
  /// - parameter hsluv: HSLuv<CGFloat>
  /// - parameter alpha: CGFloat
  public convenience init<Value: BinaryFloatingPoint>(hsluv: HSLuv<Value>, alpha: CGFloat) {
    let rgb = hsluvToRgb(hsluv)
    self.init(red: CGFloat(rgb.r), green: CGFloat(rgb.g), blue: CGFloat(rgb.b), alpha: alpha)
  }

  /// Initializes and returns a UIColor object using the specified opacity and HPLuv color space
  /// component values.
  ///
  /// - parameter hpluv: HPLuv<CGFloat>
  /// - parameter alpha: CGFloat
  public convenience init(hpluv: HPLuv<CGFloat>, alpha: CGFloat) {
    let rgb = hpluvToRgb(hpluv)
    self.init(red: rgb.r, green: rgb.g, blue: rgb.b, alpha: alpha)
  }

  /// Convenience function to wrap the behavior of getRed(red:green:blue:alpha:)
  ///
  /// - returns: (rgb: RGB<CGFloat>, alpha: CGFloat)
  public func rgbaComponents() -> (rgb: RGB<CGFloat>, a: CGFloat) {
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var alpha: CGFloat = 0.0

    getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    return (RGB(r: red, g: green, b: blue), a: alpha)
  }

  /// Convenience function to wrap the behavior of getHue(:saturation:brightness:alpha:)
  ///
  /// - returns: (hsb: HSB<CGFloat>, alpha: CGFloat)
  public func hsbComponents() -> (hsb: HSB<CGFloat>, alpha: CGFloat) {
    var hue: CGFloat = 0.0
    var saturation: CGFloat = 0.0
    var brightness: CGFloat = 0.0
    var alpha: CGFloat = 0.0

    getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
    return (HSB(h: hue, s: saturation, b: brightness), alpha: alpha)
  }
}
#endif

#if os(OSX)
import AppKit

extension NSColor {
  /// Initializes an NSColor object using the specified opacity and HSLuv color space component
  /// values.
  ///
  /// - parameter hue: CGFloat
  /// - parameter saturation: CGFloat
  /// - parameter lightness: CGFloat
  /// - parameter alpha: CGFloat
  public convenience init(hue: CGFloat, saturation: CGFloat, lightness: CGFloat, alpha: CGFloat) {
    let rgb = hsluvToRgb(HSLuv(h: hue, s: saturation, l: lightness))
    self.init(red: rgb.r, green: rgb.g, blue: rgb.b, alpha: alpha)
  }

  /// Initializes an NSColor object using the specified opacity and HSLuv color space component
  /// values.
  ///
  /// - parameter hsluv: HSLuv
  /// - parameter alpha: Double
  public convenience init(hsluv: HSLuv<CGFloat>, alpha: CGFloat) {
    let rgb = hsluvToRgb(hsluv)
    self.init(red: rgb.r, green: rgb.g, blue: rgb.b, alpha: alpha)
  }

  /// Initializes an NSColor object using the specified opacity and HPLuv color space component
  /// values.
  ///
  /// - parameter hpluv: HPLuv
  /// - parameter alpha: Double
  public convenience init(hpluv: HPLuv<CGFloat>, alpha: CGFloat) {
    let rgb = hpluvToRgb(hpluv)
    self.init(red: rgb.r, green: rgb.g, blue: rgb.b, alpha: alpha)
  }

  /// Convenience function to wrap the behavior of getRed(red:green:blue:alpha:)
  ///
  /// - returns: (rgb: RGB, alpha: CGFloat)
  public func rgbaComponents() -> (rgb: RGB<CGFloat>, a: CGFloat) {
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var alpha: CGFloat = 0.0

    getRed(&red, green: &green, blue: &blue, alpha: &alpha)

    return (RGB(r: red, g: green, b: blue), a: alpha)
  }

  /// Convenience function to wrap the behavior of getHue(:saturation:brightness:alpha:)
  ///
  /// - returns: (hue: Double, saturation: Double, brightness: Double, alpha: Double)
  public func hsbComponents() -> (hsb: HSB<CGFloat>, alpha: CGFloat) {
    var hue: CGFloat = 0.0
    var saturation: CGFloat = 0.0
    var brightness: CGFloat = 0.0
    var alpha: CGFloat = 0.0

    getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

    return (HSB(h: hue, s: saturation, b: brightness), alpha: alpha)
  }
}
#endif  // canImport(SwiftUI)
