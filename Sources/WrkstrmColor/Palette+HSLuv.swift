public extension Palette {

  static func hsluvGradient<V: BinaryFloatingPoint>(
    for gradient: Gradient,
    index: Int,
    count: Int,
    reversed: Bool = false) -> HSLuv<V>
  {
    var dIndex = V(index)
    let dCount = V(count)

    if reversed {
      dIndex = dCount - dIndex
    }
    let ratio = dIndex / dCount
    let hsLuv: HSLuv<V> =
      switch gradient
    {
    case .red:
      HSLuv(
        h: 12.2,
        s: 100.0 - 33.0 * ratio,
        l: 30.0 + 30.0 * ratio)

    case .blue:
      HSLuv(
        h: 258.6,
        s: 100.0 - 33.0 * ratio,
        l: 30.0 + 30.0 * ratio)

    case .green:
      HSLuv(
        h: 127.7,
        s: 100.0 - 33.0 * ratio,
        l: 50.0 + 25.0 * ratio)

    case .yellow:
      HSLuv(
        h: 86,
        s: 100.0 - 33.0 * ratio,
        l: 70 + 30.0 * ratio)

    case .black:
      HSLuv(
        h: 0,
        s: 0,
        l: 0 + 40.0 * ratio)

    case .white:
      HSLuv(
        h: 0,
        s: 0,
        l: 60.0 + 40.0 * ratio)
    }
    return hsLuv
  }
}
