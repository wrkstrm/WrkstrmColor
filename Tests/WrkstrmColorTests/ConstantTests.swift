import Foundation
import XCTest

@testable import WrkstrmColor

// TODO: Add HPLuv tests

class ConstantTests: XCTestCase {
  let rgbRangeTolerance = 0.000_000_001
  let snapshotTolerance = 0.000_000_001

  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the
    // class.

    continueAfterFailure = false
  }

  func constantTest() {
    XCTAssert(true, "Default test case")
  }
}
