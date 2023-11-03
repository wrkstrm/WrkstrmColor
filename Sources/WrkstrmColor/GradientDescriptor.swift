import Foundation

public struct Delta<Value: ComponentValue> {
  public static func `static`(_ component: Value) -> Delta<Value> {
    Delta(static: component)
  }

  enum `Type` {
    case `static`

    case increasing

    case decreasing
  }

  let range: ClosedRange<Value>

  let type: Type

  public init(start: Value, end: Value) {
    if start == end {
      type = .static
      range = (start...end)
    } else if start < end {
      type = .increasing
      range = (start...end)
    } else {
      type = .decreasing
      range = (end...start)
    }
  }

  public init(static value: Value) {
    type = .static
    range = (value...value)
  }

  var magnitude: Value { range.upperBound - range.lowerBound }
}

public protocol Scalable {
  associatedtype Value: ComponentValue

  static func scaled(newComponents: Components<Value>) -> Self
}

public protocol Gradient {
  associatedtype S: Scalable  // swiftlint:disable:this type_name

  var aRange: Delta<S.Value> { get }

  var bRange: Delta<S.Value> { get }

  var cRange: Delta<S.Value> { get }
}

extension Gradient {
  func ratioCalculator(
    delta: Delta<S.Value>,
    ratio: S.Value) -> S.Value
  {
    switch delta.type {
      case .static:
        delta.range.lowerBound

      case .increasing:
        delta.range.lowerBound + delta.magnitude * ratio

      case .decreasing:
        delta.range.upperBound - delta.magnitude * ratio
    }
  }

  public func color(for index: S.Value, count: S.Value) -> S {
    let ratio = index / count

    let aNewComponent = ratioCalculator(delta: aRange, ratio: ratio)

    let bNewComponent = ratioCalculator(delta: bRange, ratio: ratio)

    let cNewComponents = ratioCalculator(delta: cRange, ratio: ratio)

    let newComponents = (a: aNewComponent, b: bNewComponent, c: cNewComponents)
    return S.scaled(newComponents: newComponents)
  }

  public func first() -> S {
    let a = aRange.type == .decreasing ? aRange.range.upperBound : aRange.range.lowerBound

    let b = bRange.type == .decreasing ? bRange.range.upperBound : bRange.range.lowerBound

    let c = cRange.type == .decreasing ? cRange.range.upperBound : cRange.range.lowerBound

    return S.scaled(newComponents: (a, b, c))
  }

  public func mid() -> S {
    let a =
      (aRange.type == .decreasing ? aRange.range.upperBound : aRange.range.lowerBound)
        + aRange.magnitude / 2

    let b =
      (bRange.type == .decreasing ? bRange.range.upperBound : bRange.range.lowerBound)
        + bRange.magnitude / 2

    let c =
      (cRange.type == .decreasing ? cRange.range.upperBound : cRange.range.lowerBound)
        + cRange.magnitude / 2

    return S.scaled(newComponents: (a, b, c))
  }

  public func last() -> S {
    let a = aRange.type == .decreasing ? aRange.range.lowerBound : aRange.range.upperBound

    let b = bRange.type == .decreasing ? bRange.range.lowerBound : bRange.range.upperBound

    let c = cRange.type == .decreasing ? cRange.range.lowerBound : cRange.range.upperBound

    return S.scaled(newComponents: (a, b, c))
  }
}

public struct GradientDescriptor<S: Scalable>: Gradient {
  public var aRange: Delta<S.Value>

  public var bRange: Delta<S.Value>

  public var cRange: Delta<S.Value>

  public var count: Int

  public init(
    count: Int,
    aRange: Delta<S.Value>,
    bRange: Delta<S.Value>,
    cRange: Delta<S.Value>)
  {
    self.count = count
    self.aRange = aRange
    self.bRange = bRange
    self.cRange = cRange
  }
}

public struct ContrastGradientDescriptor<S: Scalable & RGBEncodable>: Gradient {
  public var aRange: Delta<S.Value>

  public var bRange: Delta<S.Value>

  public var cRange: Delta<S.Value>

  public var minContrast: S.Value

  public init(
    minContrast: S.Value,
    aRange: Delta<S.Value>,
    bRange: Delta<S.Value>,
    cRange: Delta<S.Value>)
  {
    self.minContrast = minContrast
    self.aRange = aRange
    self.bRange = bRange
    self.cRange = cRange
  }
}
