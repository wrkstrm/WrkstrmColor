import Foundation

extension RGBEncodable {
  /// Relative luminance of a color according to W3's WCAG 2.0:
  /// https://www.w3.org/TR/WCAG20/#relativeluminancedef
  var luminance: Value {
    let (red, green, blue) = components as Components<Value>
    return 0.212_6 * red + 0.715_2 * green + 0.072_2 * blue
  }

  var luminanceSaturated: Value {
    let (red, green, blue) = components
    let luminance =
      0.212_6 * invGamSRGB(inverseColor: red) + 0.715_2 * invGamSRGB(inverseColor: green) + 0.072_2
      * invGamSRGB(inverseColor: blue)
    return min(1, max(0, luminance))
  }

  @inline(__always)
  func invGamSRGB(inverseColor: Value) -> Value {
    guard inverseColor <= 0.039_28 else {
      return Value(pow(Double((inverseColor + 0.055) / 1.055), 2.4))
    }
    return inverseColor / 12.92
  }

  /// Contrast ratio between two colors according to W3's WCAG 2.0:
  /// https://www.w3.org/TR/WCAG20/#contrast-ratiodef
  func contrastRatio(to other: some RGBEncodable) -> Value {
    let ourLuminance = luminance
    let theirLuminance = other.luminance
    let lighterColor: Value = .init(min(Double(ourLuminance), Double(theirLuminance)))
    let darkerColor: Value = .init(max(Double(ourLuminance), Double(theirLuminance)))
    return 1 / ((lighterColor + 0.05) / (darkerColor + 0.05))
  }
}

#if canImport(UIKit)
  import UIKit

  extension UIColor: Scalable {
    public static func scaled(newComponents: (CGFloat, CGFloat, CGFloat)) -> Self {
      Self(red: newComponents.0, green: newComponents.1, blue: newComponents.2, alpha: 1.0)
    }

    public var values: (CGFloat, CGFloat, CGFloat) { components }
  }

  extension UIColor: RGBEncodable {
    public var components: (CGFloat, CGFloat, CGFloat) {
      let rgb = rgbaComponents().rgb
      return (CGFloat(rgb.r), CGFloat(rgb.g), CGFloat(rgb.b))
    }

    public func rgbComponents() -> (CGFloat, CGFloat, CGFloat) { values }
  }

  extension UIColor {
    static let redGradient = GradientDescriptor<UIColor>(
      count: 10,
      aRange: Delta(start: 1, end: 0),
      bRange: Delta(start: 0, end: 0),
      cRange: Delta(start: 0, end: 0),
    )
  }

  extension UIFont {
    private var weight: CGFloat {
      guard
        let traits = fontDescriptor.object(forKey: .traits)
          as? [UIFontDescriptor.AttributeName: Any],
        let weight = traits[.traits] as? CGFloat
      else { return 0 }
      return weight
    }

    var isBold: Bool { fontDescriptor.symbolicTraits.contains(.traitBold) || weight > 0.0 }
  }

  extension RGBEncodable {
    /// Determines whether the contrast between this `UIColor` and the provided
    /// `UIColor` is sufficient to meet the recommendations of W3's WCAG 2.0.
    ///
    /// The recommendation is that the contrast ratio between text and its
    /// background should be at least 4.5:1 for small text and at least
    /// 3.0:1 for larger text.
    func sufficientContrast(
      to other: some RGBEncodable,
      with font: UIFont = UIFont.preferredFont(forTextStyle: .body),
    ) -> Bool {
      let pointSizeThreshold: Value = font.isBold ? 14.0 : 18.0
      let contrastRatioThreshold: Value =
        Value(font.fontDescriptor.pointSize) < pointSizeThreshold ? 4.5 : 3.0
      return contrastRatio(to: other) > contrastRatioThreshold
    }
  }
#endif
