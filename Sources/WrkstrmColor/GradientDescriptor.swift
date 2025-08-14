import Foundation

/// A struct to represent the delta (difference or range) for a generic value.
public struct Delta<Value: ComponentValue>: Sendable {
  /// Creates a static delta with a constant component value.
  public static func `static`(_ component: Value) -> Delta<Value> {
    .init(static: component)
  }

  /// Defines the type of delta, whether it is static, increasing, or decreasing.
  enum `Type` {
    case `static`
    case increasing
    case decreasing
  }

  /// The range of values for the delta.
  let range: ClosedRange<Value>

  /// The type of delta.
  let type: Type

  /// Initializes a delta with a start and end value, determining its type based on their
  /// relationship.
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

  /// Initializes a static delta with a single value.
  public init(static value: Value) {
    type = .static
    range = (value...value)
  }

  /// Calculates the magnitude of the delta.
  var magnitude: Value { range.upperBound - range.lowerBound }
}

/// A protocol defining an entity that can be scaled.
public protocol Scalable {
  associatedtype Value: ComponentValue

  /// Scales the entity to new components.
  static func scaled(newComponents: Components<Value>) -> Self
}

/// A protocol representing a gradient.
public protocol Gradient {
  associatedtype S: Scalable  // swiftlint:disable:this type_name

  var aRange: Delta<S.Value> { get }
  var bRange: Delta<S.Value> { get }
  var cRange: Delta<S.Value> { get }
}

/// Extension of the Gradient protocol to include utility functions.
extension Gradient {
  /// Calculates the value in the delta range based on the given ratio.
  internal func ratioCalculator(delta: Delta<S.Value>, ratio: S.Value) -> S.Value {
    switch delta.type {
    case .static:
      delta.range.lowerBound

    case .increasing:
      delta.range.lowerBound + delta.magnitude * ratio

    case .decreasing:
      delta.range.upperBound - delta.magnitude * ratio
    }
  }

  /// Generates a color for the given index and count.
  public func color(for index: S.Value, count: S.Value) -> S {
    let ratio = index / count
    // Calculate new components based on the ratio and deltas.
    let aNewComponent = ratioCalculator(delta: aRange, ratio: ratio)
    let bNewComponent = ratioCalculator(delta: bRange, ratio: ratio)
    let cNewComponent = ratioCalculator(delta: cRange, ratio: ratio)

    let newComponents = (a: aNewComponent, b: bNewComponent, c: cNewComponent)
    return S.scaled(newComponents: newComponents)
  }

  /// Returns the first color in the gradient.
  public func first() -> S {
    // Calculate the start values based on the delta types.
    let a = aRange.type == .decreasing ? aRange.range.upperBound : aRange.range.lowerBound
    let b = bRange.type == .decreasing ? bRange.range.upperBound : bRange.range.lowerBound
    let c = cRange.type == .decreasing ? cRange.range.upperBound : cRange.range.lowerBound

    return S.scaled(newComponents: (a, b, c))
  }

  /// Returns the middle color in the gradient.
  public func mid() -> S {
    // Calculate the middle values based on the delta types and magnitudes.
    let a =
      (aRange.type == .decreasing ? aRange.range.upperBound : aRange.range.lowerBound) + aRange
      .magnitude / 2
    let b =
      (bRange.type == .decreasing ? bRange.range.upperBound : bRange.range.lowerBound) + bRange
      .magnitude / 2
    let c =
      (cRange.type == .decreasing ? cRange.range.upperBound : cRange.range.lowerBound) + cRange
      .magnitude / 2

    return S.scaled(newComponents: (a, b, c))
  }

  /// Returns the last color in the gradient.
  public func last() -> S {
    // Calculate the end values based on the delta types.
    let a = aRange.type == .decreasing ? aRange.range.lowerBound : aRange.range.upperBound
    let b = bRange.type == .decreasing ? bRange.range.lowerBound : bRange.range.upperBound
    let c = cRange.type == .decreasing ? cRange.range.lowerBound : cRange.range.upperBound
    return S.scaled(newComponents: (a, b, c))
  }
}

public struct GradientDescriptor<S: Scalable>: Gradient, Sendable {
  public var aRange: Delta<S.Value>
  public var bRange: Delta<S.Value>
  public var cRange: Delta<S.Value>
  public var count: Int
  public init(
    count: Int,
    aRange: Delta<S.Value>,
    bRange: Delta<S.Value>,
    cRange: Delta<S.Value>,
  ) {
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
    cRange: Delta<S.Value>,
  ) {
    self.minContrast = minContrast
    self.aRange = aRange
    self.bRange = bRange
    self.cRange = cRange
  }
}
