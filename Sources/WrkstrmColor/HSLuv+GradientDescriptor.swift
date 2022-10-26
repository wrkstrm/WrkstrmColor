extension HSLuv: Scalable {

  public var values: (Value, Value, Value) { (h, s, l) }

  public static func scaled(newComponents: (Value, Value, Value)) -> HSLuv {
    HSLuv(h: newComponents.0, s: newComponents.1, l: newComponents.2)
  }
}

extension HSLuv: RGBEncodable {

  public func rgbComponents() -> (Value, Value, Value) { hsluvToRgb(self).components }
}

public extension HSLuv {

  static var redGradient: GradientDescriptor<HSLuv<Value>> {
    GradientDescriptor(
      count: 10,
      aRange: .static(12.2),
      bRange: Delta(start: 100.0, end: 50),
      cRange: Delta(start: 30, end: 60))
  }

  static func blueGradient(minContrast: Value = 1.1) -> ContrastGradientDescriptor<
    HSLuv<Value>
  > {
    ContrastGradientDescriptor(
      minContrast: minContrast,
      aRange: .static(258.6),
      bRange: Delta(start: 100, end: 50),
      cRange: Delta(start: 30, end: 60))
  }

  static var greenGradient: GradientDescriptor<HSLuv<Value>> {
    GradientDescriptor(
      count: 10,
      aRange: .static(127.7),
      bRange: Delta(start: 100, end: 50),
      cRange: Delta(start: 50, end: 70))
  }

  static var blackGradient: GradientDescriptor<HSLuv<Value>> {
    GradientDescriptor(
      count: 10,
      aRange: .static(0),
      bRange: .static(0),
      cRange: Delta(start: 0, end: 40))
  }

  static var whiteGradient: GradientDescriptor<HSLuv<Value>> {
    GradientDescriptor(
      count: 10,
      aRange: .static(0),
      bRange: .static(0),
      cRange: Delta(start: 100, end: 60))
  }
}

public extension HSLuv {

  static func black() -> HSLuv<Value> {
    HSLuv<Value>(h: 0, s: 0, l: 0)
  }
}
