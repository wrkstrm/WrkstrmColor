import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
  [testCase(HSLuvTests.allTests)]
}
#endif
