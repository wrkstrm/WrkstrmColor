// Extends `ClosedRange` for types conforming to `BinaryInteger`.
extension ClosedRange where ClosedRange.Bound: BinaryInteger {
  // Computes the magnitude (size) of the range.
  public var magnitude: ClosedRange.Bound {
    // Subtracting the lower bound from the upper bound to find the range size.
    upperBound - lowerBound
  }

  // Calculates the mid-point of the range.
  public var midPoint: ClosedRange.Bound {
    // Adding half of the magnitude to the lower bound to find the middle value.
    lowerBound + magnitude / 2
  }
}

// Extends `GradientDescriptor` to conform to `Sequence`, enabling iteration over its elements.
extension GradientDescriptor: Sequence {
  /// Creates an iterator for the gradient descriptor.
  public __consuming func makeIterator() -> AnyIterator<S> {
    var index = 0  // Starting index for iteration.

    return AnyIterator<S> {
      defer { index += 1 }  // Ensures the index is incremented after returning a color.

      // Checks if the iteration has reached past the end of the gradient descriptor.
      guard index <= self.count else {
        return nil  // Ends the iteration when all elements are iterated over.
      }

      // Returns a color at the current index, computed from the gradient descriptor.
      return self.color(for: S.Value(index), count: S.Value(self.count))
    }
  }
}

// Extends `ContrastGradientDescriptor` to conform to `Sequence`.
extension ContrastGradientDescriptor: Sequence {
  /// Creates an iterator for the contrast gradient descriptor.
  public __consuming func makeIterator() -> AnyIterator<S> {
    var currentColor: S?  // Holds the current color in the iteration.
    let maxColors = Int.max  // Defines the maximum number of colors.
    var colorRange = (0...maxColors)  // Defines the range for color selection.

    return AnyIterator<S> {
      // Initializes the first color if not already set.
      guard let current = currentColor else {
        currentColor = self.color(
          for: S.Value(colorRange.lowerBound),
          count: S.Value(maxColors)
        )
        return currentColor
      }

      // Stops iteration if the range is reduced to a single color.
      guard colorRange.magnitude > 1 else { return nil }

      // Iterates to find a color with a contrast ratio within the acceptable range.
      while colorRange.magnitude > 1 {
        let contrast = current.contrastRatio(
          to: self.color(
            for: S.Value(colorRange.midPoint),
            count: S.Value(maxColors)
          ))

        // Narrows down the range based on the contrast ratio.
        if contrast < self.minContrast {
          colorRange = colorRange.clamped(to: colorRange.midPoint...colorRange.upperBound)
        } else {
          colorRange = colorRange.clamped(to: colorRange.lowerBound...colorRange.midPoint)
        }
      }

      // Selects the next color in the narrowed range and prepares for the next iteration.
      currentColor = self.color(for: S.Value(colorRange.lowerBound), count: S.Value(maxColors))
      colorRange = ((colorRange.lowerBound + 1)...maxColors)
      return currentColor
    }
  }
}
