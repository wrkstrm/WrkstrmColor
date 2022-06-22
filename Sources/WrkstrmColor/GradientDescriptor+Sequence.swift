extension ClosedRange where ClosedRange.Bound: BinaryInteger {

  var magnitude: ClosedRange.Bound { upperBound - lowerBound }

  var midPoint: ClosedRange.Bound { lowerBound + magnitude / 2 }
}

extension GradientDescriptor: Sequence {

  public __consuming func makeIterator() -> AnyIterator<S> {
    var index = 0
    return AnyIterator<S> {
      defer { index += 1 }
      if index <= self.count {
        return self.color(for: S.Value(index), count: S.Value(self.count))
      } else {
        return nil
      }
    }
  }
}

extension ContrastGradientDescriptor: Sequence {

  public __consuming func makeIterator() -> AnyIterator<S> {
    var currentColor: S?
    let maxColors = Int.max
    var colorRange = (0...maxColors)
    return AnyIterator<S> {
      guard let current = currentColor else {
        currentColor = self.color(
          for: S.Value(colorRange.lowerBound),
          count: S.Value(maxColors))
        return currentColor
      }
      guard colorRange.magnitude > 1 else { return nil }
      while colorRange.magnitude > 1 {
        let contrast = current.contrastRatio(
          to: self.color(
            for: S.Value(colorRange.midPoint),
            count: S.Value(maxColors)))
        if contrast < self.minContrast {
          colorRange = colorRange.clamped(to: colorRange.midPoint...colorRange.upperBound)
        } else {
          colorRange = colorRange.clamped(to: colorRange.lowerBound...colorRange.midPoint)
        }
      }
      currentColor = self.color(for: S.Value(colorRange.lowerBound), count: S.Value(maxColors))
      colorRange = ((colorRange.lowerBound + 1)...maxColors)
      return currentColor
    }
  }
}
