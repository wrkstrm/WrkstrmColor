import Foundation

// MARK: - XYZ/RGB Conversion

extension XYZ {
  func fromLinear<T: ComponentValue>(_ c: T) -> T {
    if c <= 0.003_130_8 {
      return 12.92 * c
    }
    return T(1.055 * pow(Double(c), 1 / 2.4) - 0.055)
  }

  var toRGB: RGB<Value> {
    let components = components
    let r = fromLinear(Value(dotProduct(Constant.m().R, b: components)))
    let g = fromLinear(Value(dotProduct(Constant.m().G, b: components)))
    let b = fromLinear(Value(dotProduct(Constant.m().B, b: components)))

    return RGB(r: r, g: g, b: b)
  }
}

extension RGB {
  func toLinear(_ component: Value) -> Value {
    let c_055 = 0.055  // swiftlint:disable:this identifier_name
    if component > 0.040_45 {
      return Value(pow((Double(component) + c_055) / (1.0 + c_055), 2.4))
    }
    return component / 12.92
  }

  var toXyz: XYZ<Value> {
    let components = RGB(r: toLinear(r), g: toLinear(g), b: toLinear(b)).components
    let x = dotProduct(Constant.mInv().X, b: components)
    let y = dotProduct(Constant.mInv().Y, b: components)
    let z = dotProduct(Constant.mInv().Z, b: components)

    return XYZ(x: x, y: y, z: z)
  }
}

// MARK: - XYZ / LUV Conversion

// In these formulas, Yn refers to the reference white point. We are using
// illuminant D65, so Yn (see refY in Maxima file) equals 1. The formula is
// simplified accordingly.

extension XYZ {
  func yToL<T: ComponentValue>(_ y: T) -> T {
    if y <= Constant.epsilon() {
      return y * Constant.kappa()
    }
    return T(116 * pow(Double(y), 1 / 3) - 16)
  }

  var toLuv: LUV<Value> {
    let varU: Value = (4 * x) / (x + (15 * y) + (3 * z))
    let varV: Value = (9 * y) / (x + (15 * y) + (3 * z))

    let l = yToL(y)

    guard l != 0 else {
      // Black will create a divide-by-zero error
      return LUV(l: 0, u: 0, v: 0)
    }

    let u = 13 * l * (varU - Constant.refU())
    let v = 13 * l * (varV - Constant.refV())

    return LUV(l: l, u: u, v: v)
  }
}

extension LUV {
  func lToY<T: ComponentValue>(_ l: T) -> T {
    if l <= 8 {
      return l / Constant.kappa()
    }
    return T(pow(Double((l + 16) / 116), 3))
  }

  var toXYZ: XYZ<Value> {
    guard l != 0 else {
      // Black will create a divide-by-zero error
      return XYZ(x: 0, y: 0, z: 0)
    }

    let varU = u / (13 * l) + Constant.refU()
    let varV = v / (13 * l) + Constant.refV()

    let y: Value = lToY(l)
    let xDivisor: Value = (varU - 4.0) * varV - varU * varV
    let x: Value = 0.0 - (9.0 * y * varU) / xDivisor
    let zNumerator: Value = 9.0 * y - (15.0 * varV * y) - (varV * x)
    let zDivisor: Value = 3.0 * varV
    let z: Value = zNumerator / zDivisor

    return XYZ(x: x, y: y, z: z)
  }
}

// MARK: - LUV / LCH Conversion

extension LUV {
  public var toLch: LCH<Value> {
    let c = Value(sqrt(pow(Double(u), 2) + pow(Double(v), 2)))

    guard c >= 0.000_000_01 else {
      // Greys: disambiguate hue
      return LCH(l: l, c: c, h: 0)
    }
    let hRad = Value(atan2(Double(v), Double(u)))
    var h = hRad * 360 / 2 / .pi

    if h < 0 {
      h = 360 + h
    }

    return LCH(l: l, c: c, h: h)
  }
}

extension LCH {
  public var toLUV: LUV<Value> {
    let hRad = h / 360 * 2 * .pi
    let u = Value(cos(Double(hRad))) * c
    let v = Value(sin(Double(hRad))) * c
    return LUV(l: l, u: u, v: v)
  }
}

// MARK: - HSLuv / LCH Conversion

/// For a given lightness and hue, return the maximum chroma that fits in
/// the RGB gamut.
func maxChroma<Value: ComponentValue>(lightness: Value, hue: Value) -> Value {
  let hrad = hue / 360 * 2 * .pi

  var lengths: [Value] = []
  for line in getBounds(lightness: lightness) {
    if let length = lengthOfRayUntilIntersect(theta: hrad, line: line) {
      lengths.append(length)
    }
  }

  return lengths.reduce(.greatestFiniteMagnitude) { min($0, $1) }
}

extension HSLuv {
  public var toLch: LCH<Value> {
    guard l <= 99.999_999_9, l >= 0.000_000_01 else {
      // White and black: disambiguate chroma
      return LCH(l: l, c: 0, h: h)
    }

    let max = maxChroma(lightness: l, hue: h)
    let c = max / 100 * s

    return LCH(l: l, c: c, h: h)
  }
}

extension LCH {
  public var toHSLuv: HSLuv<Value> {
    guard l <= 99.999_999_9, l >= 0.000_000_01 else {
      // White and black: disambiguate saturation
      return HSLuv(h: Value(h), s: Value(0), l: Value(l))
    }

    let max = maxChroma(lightness: l, hue: h)
    let s = c / max * 100

    return HSLuv(h: Value(h), s: Value(s), l: Value(l))
  }
}

// MARK: - Pastel HSLuv (HPLuv) / LCH Conversion

/// For given lightness, returns the maximum chroma. Keeping the chroma value
/// below this number will ensure that for any hue, the color is within the RGB
/// gamut.
func maxChroma<Value: ComponentValue>(lightness: Value) -> Value {
  var lengths: [Value] = []

  // swiftlint:disable:next identifier_name
  for (m1, b1) in getBounds(lightness: lightness) {
    // swiftlint:disable:previous identifier_name
    // x where line intersects with perpendicular running though (0, 0)
    let x = intersectLine((m1, b1), (-1 / m1, 0))
    lengths.append(distanceFromPole((x, b1 + x * m1)))
  }

  return lengths.reduce(.greatestFiniteMagnitude) { min($0, $1) }
}

extension HPLuv {
  public var toLCH: LCH<Value> {
    guard l <= 99.999_999_9, l >= 0.000_000_01 else {
      // White and black: disambiguate chroma
      return LCH(l: 1, c: 0, h: h)
    }

    let max = maxChroma(lightness: l)
    let c = max / 100 * s

    return LCH(l: l, c: c, h: h)
  }
}

extension LCH {
  public var toHPLuv: HPLuv<Value> {
    guard l <= 99.999_999_9, l >= 0.000_000_01 else {
      // White and black: disambiguate saturation
      return HPLuv(h: Value(h), s: Value(0), l: Value(l))
    }

    let max = maxChroma(lightness: l)
    let s = c / max * 100

    return HPLuv(h: Value(h), s: Value(s), l: Value(l))
  }
}

// MARK: - RGB / Hex Conversion

extension RGB {
  public func round(_ value: Double, places: Double) -> Double {
    let divisor = pow(10.0, places)
    return Foundation.round(value * divisor) / divisor
  }

  public func getHexString(_ channel: Double) -> String {
    // swiftlint:disable:next identifier_name
    var ch = round(channel, places: 6)

    if ch < 0 || ch > 1 {
      // TODO: Implement Swift thrown errors
      fatalError("Illegal RGB value: \(ch)")
    }

    ch = Foundation.round(ch * 255.0)

    return String(Int(ch), radix: 16, uppercase: false).padding(
      toLength: 2,
      withPad: "0",
      startingAt: 0
    )
  }

  public var toHex: Hex {
    let r = getHexString(Double(r))
    let g = getHexString(Double(g))
    let b = getHexString(Double(b))

    return Hex("#\(r)\(g)\(b)")
  }
}

extension Hex {
  // This function is based on a comment by mehawk on gist arshad/de147c42d7b3063ef7bc.
  public func toRgb<Value: ComponentValue>() -> RGB<Value> {
    let string = string.replacingOccurrences(of: "#", with: "")

    var rgbValue: UInt64 = 0

    Scanner(string: string).scanHexInt64(&rgbValue)

    return RGB(
      r: Value(Double((rgbValue & 0xFF0000) >> 16) / 255.0),
      g: Value(Double((rgbValue & 0x00FF00) >> 8) / 255.0),
      b: Value(Double(rgbValue & 0x0000FF) / 255.0)
    )
  }
}

// MARK: - HSLuv Conversion Requirements

public func hsluvToRgb<Value: ComponentValue>(_ hsluv: HSLuv<Value>) -> RGB<Value> {
  hsluv.toLch.toLUV.toXYZ.toRGB
}

public func hpluvToRgb<Value: ComponentValue>(_ hpluv: HPLuv<Value>) -> RGB<Value> {
  hpluv.toLCH.toLUV.toXYZ.toRGB
}

public func rgbToHsluv<Value: ComponentValue>(_ rgb: RGB<Value>) -> HSLuv<Value> {
  rgb.toXyz.toLuv.toLch.toHSLuv
}

public func rgbToHpluv<Value: ComponentValue>(_ rgb: RGB<Value>) -> HPLuv<Value> {
  rgb.toXyz.toLuv.toLch.toHPLuv
}
