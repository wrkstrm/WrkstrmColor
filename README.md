# WrkstrmColor

[![wrkstrm-color](https://github.com/wrkstrm/WrkstrmColor/actions/workflows/wrkstrm-color-build.yml/badge.svg)](https://github.com/wrkstrm/WrkstrmColor/actions/workflows/wrkstrm-color-build.yml)

[![MIT License](https://img.shields.io/badge/license-MIT%20License-blue.svg)](LICENSE)

The `wrkstrm` port of [HSLuvSwift](http://www.hsluv.org) (revision 4), courtesy of [Clay Smith](https://github.com/stphnclysmth)

[Explanation, demo, ports etc.](http://www.hsluv.org)

## USAGE

This package extends SwiftUI `Color` as well as `NSColor` and `UIColor` with initializers that create a color from HSLuv or HPLuv values.

```swift
// SwiftUI
let color: Color = .init(hue: 360.0, saturation: 100.0, lightness: 100.0, opacity: 1.0)

// UIKit
let color: UIColor = .init(hsluv: .init(h: 360.0, s: 100.0, l: 100.0), alpha: 1.0)

// AppKit
let color: NSColor = .init(hpluv: .init(h: 360.0, s: 100.0, l: 100.0), alpha: 1.0)
```

## TODO

* Finish HPLuv implementation

## License

See [License](LICENSE)
