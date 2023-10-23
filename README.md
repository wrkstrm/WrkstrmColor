# WrkstrmColor

[![wrkstrm-color](https://github.com/wrkstrm/laussat/actions/workflows/wrkstrm-color-build.yml/badge.svg)](https://github.com/wrkstrm/laussat/actions/workflows/wrkstrm-color-build.yml)

[![MIT License](https://img.shields.io/badge/license-MIT%20License-blue.svg)](LICENSE)

The `wrkstrm` port of [HSLuvSwift](http://www.hsluv.org) (revision 4), courtesy of [Clay Smith](https://github.com/stphnclysmth)

[Explanation, demo, ports etc.](http://www.hsluv.org)

## USAGE

This framework adds a single initializer on the OS-specific color class to create a color from HSLuv parameters. The initializer takes the same parameters on both OSX and iOS.

```swift
// OSX
let color = NSColor(hue: 360.0, saturation: 100.0, lightness: 100.0, alpha: 1.0)

// iOS
let color = UIColor(hue: 360.0, saturation: 100.0, lightness: 100.0, alpha: 1.0)
```

## TODO

* Finish HPLuv implementation
* Improve tests and add continuous integration testing
* Add usage documentation

## License

See [License](LICENSE)
