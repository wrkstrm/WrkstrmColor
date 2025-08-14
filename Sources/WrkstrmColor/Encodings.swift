/// Hexadecimal color
public struct Hex {
  public let string: String

  public init(_ string: String) {
    self.string = string
  }
}

public protocol RGBEncodable: ComponentConvertible {
  func rgbComponents() -> Components<Value>
}

/// Red, Green, Blue (RGB)
public struct RGB<Value: BinaryFloatingPoint & Sendable>: ComponentConvertible, RGBEncodable {
  /// Red color channel
  public var r: Value

  /// Green color channel
  public var g: Value

  /// Blue color channel
  public var b: Value

  public var components: Components<Value> { (r, g, b) }

  public init(r: Value, g: Value, b: Value) {
    self.r = r
    self.g = g
    self.b = b
  }

  public func rgbComponents() -> (Value, Value, Value) { components }
}

/// HSB: Hue(man), Saturation, Brightness in RGB color space
public struct HSB<Value: BinaryFloatingPoint & Sendable>: ComponentConvertible {
  /// Hue(man)
  public var h: Value

  /// Saturation
  public var s: Value

  /// Brightness
  public var b: Value

  public var components: Components<Value> { (h, s, b) }

  public init(h: Value, s: Value, b: Value) {
    self.h = h
    self.s = s
    self.b = b
  }
}

/// Luminance, Blue-stimulation, Cone-response [CIE 1931] (XYZ)
public struct XYZ<Value: BinaryFloatingPoint & Sendable>: ComponentConvertible {
  public var x: Value

  public var y: Value

  public var z: Value

  public var components: Components<Value> { (x, y, z) }

  public init(x: Value, y: Value, z: Value) {
    self.x = x
    self.y = y
    self.z = z
  }
}

/// L*, u*, v* [CIE 1976] (LUV)
public struct LUV<Value: BinaryFloatingPoint & Sendable>: ComponentConvertible {
  public var l: Value

  public var u: Value

  public var v: Value

  public var components: Components<Value> { (l, u, v) }

  public init(l: Value, u: Value, v: Value) {
    self.l = l
    self.u = u
    self.v = v
  }
}

/// Lightness, Chroma, Hue (LCH)
public struct LCH<Value: BinaryFloatingPoint & Sendable>: ComponentConvertible {
  /// Lightness channel
  public var l: Value

  /// Chroma channel
  public var c: Value

  /// Hue channel
  public var h: Value

  public var components: Components<Value> { (l, c, h) }

  public init(l: Value, c: Value, h: Value) {
    self.l = l
    self.c = c
    self.h = h
  }
}

public protocol HSLEncodable: ComponentConvertible {
  var h: Value { get }

  var s: Value { get }

  var l: Value { get }
}

extension HSLEncodable {
  public var components: (Value, Value, Value) { (h, s, l) }
}

/// HSLuv: Hue(man), Saturation, Lightness (HSLuv)
public struct HSLuv<Value: BinaryFloatingPoint & Sendable>: HSLEncodable {
  /// Hue(man)
  public var h: Value

  /// Saturation
  public var s: Value

  /// Lightness
  public var l: Value

  public init(h: Value, s: Value, l: Value) {
    self.h = h
    self.s = s
    self.l = l
  }
}

/// HPLuv: Hue(pastel), Saturation, Lightness (HPLuv)
public struct HPLuv<Value: BinaryFloatingPoint & Sendable>: HSLEncodable {
  /// Hue(pastel)
  public var h: Value

  /// Saturation
  public var s: Value

  /// Lightness
  public var l: Value

  public init(h: Value, s: Value, l: Value) {
    self.h = h
    self.s = s
    self.l = l
  }
}
