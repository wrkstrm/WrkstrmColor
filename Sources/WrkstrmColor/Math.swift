import Foundation

typealias MType<Value: BinaryFloatingPoint> =
  (
    R: Components<Value>,
    G: Components<Value>,
    B: Components<Value>
  )

typealias MInvType<Value: BinaryFloatingPoint> =
  (
    X: Components<Value>,
    Y: Components<Value>,
    Z: Components<Value>
  )

/// Generic Vector type.
typealias Vector<Value: BinaryFloatingPoint> = (Value, Value)

// Using structs instead of tuples to prevent implicit conversion, which was making debugging
// difficult.

public typealias ComponentValue = BinaryFloatingPoint & ExpressibleByIntegerLiteral

public typealias Components<Value: ComponentValue> = (Value, Value, Value)

public protocol ComponentConvertible {
  associatedtype Value: ComponentValue

  var components: Components<Value> { get }
}

// MARK: - Color Constants

enum Constant {
  // Components<Double>
  static func m<Value: ComponentValue>() -> MType<Value> {
    (
      R: Components(3.240_969_941_904_521_4, -1.537_383_177_570_093_5, -0.498_610_760_293_003_28),
      G: Components(-0.969_243_636_280_879_83, 1.875_967_501_507_720_7, 0.041_555_057_407_175_613),
      B: Components(0.055_630_079_696_993_609, -0.203_976_958_888_976_57, 1.056_971_514_242_878_6)
    )
  }

  // Components<Double>
  static func mInv<Value: ComponentValue>() -> MInvType<Value> {
    (
      X: Components(0.412_390_799_265_959_48, 0.357_584_339_383_877_96, 0.180_480_788_401_834_29),
      Y: Components(0.212_639_005_871_510_36, 0.715_168_678_767_755_93, 0.072_192_315_360_733_715),
      Z: Components(0.019_330_818_715_591_851, 0.119_194_779_794_625_99, 0.950_532_152_249_660_58)
    )
  }

  // Hard-coded D65 standard illuminant
  static func refU<Value: ComponentValue>() -> Value {
    0.197_830_006_642_836_81
  }

  static func refV<Value: ComponentValue>() -> Value {
    0.468_319_994_938_791
  }

  // CIE LUV constants
  static func kappa<Value: ComponentValue>() -> Value {
    903.296_296_296_296_3
  }

  static func epsilon<Value: ComponentValue>() -> Value {
    0.008_856_451_679_035_630_8
  }
}

// MARK: - Vector math

///  For a given lightness, return a list of 6 lines in slope-intercept form that represent the
///  bounds in CIELUV, stepping over which will push a value out of the RGB gamut.
///
/// - parameter lightness: Double
func getBounds<Value: ComponentValue>(lightness: Value) -> [Vector<Value>] {
  let sub1 = Value(pow(Double(lightness) + 16, 3) / 1_560_896)
  let sub2: Value = sub1 > Constant.epsilon() ? sub1 : lightness / Constant.kappa()

  var result: [Vector<Value>] = []

  let mirror: Mirror = .init(reflecting: Constant.m() as MType<Value>)
  for (_, value) in mirror.children {
    // swiftlint:disable:next identifier_name force_cast
    let (m1, m2, m3) = value as! Components<Value>  // swiftlint:disable:this identifier_name
    // swiftlint:disable:previous identifier_name
    let targets: [Value] = [0.0, 1.0]
    for target in targets {
      let top1: Value = (284_517 * m1 - 94_839 * m3) * sub2
      let multiple: Value = (838_422 * m3 + 769_860 * m2 + 731_718 * m1)
      let top2: Value = multiple * lightness * sub2 - 769_860 * target * lightness
      let bottom: Value = (632_260 * m3 - 126_452 * m2) * sub2 + 126_452 * target

      result.append((top1 / bottom, top2 / bottom))
    }
  }
  return result
}

func intersectLine<Value: ComponentValue>(
  _ line1: Vector<Value>,
  _ line2: Vector<Value>
) -> Value {
  (line1.1 - line2.1) / (line2.0 - line1.0)
}

func distanceFromPole<Value: ComponentValue>(_ point: Vector<Value>) -> Value {
  Value(sqrt(pow(Double(point.0), 2) + pow(Double(point.1), 2)))
}

func lengthOfRayUntilIntersect<Value: ComponentValue>(theta: Value, line: Vector<Value>) -> Value? {
  // theta  -- angle of ray starting at (0, 0)
  // m, b   -- slope and intercept of line
  // x1, y1 -- coordinates of intersection
  // length -- length of ray until it intersects with line
  //
  // b + m * x1          = y1
  // length             >= 0
  // length * cos(theta) = x1
  // length * sin(theta) = y1
  //
  //
  // b + m * (length * cos(theta)) = length * sin(theta)
  // b = length * sin(hrad) - m * length * cos(theta)
  // b = length * (sin(hrad) - m * cos(hrad))
  // len = b / (sin(hrad) - m * cos(hrad))

  // swiftlint:disable:next identifier_name identifier_name
  let (m1, b1) = line
  let length = b1 / Value(sin(Double(theta)) - Double(m1) * cos(Double(theta)))

  if length < 0 {
    return nil
  }

  return length
}

func dotProduct<Value: ComponentValue>(_ a: Components<Value>, b: Components<Value>) -> Value {
  var ret: Value = 0.0
  ret += a.0 * b.0
  ret += a.1 * b.1
  ret += a.2 * b.2
  return ret
}
