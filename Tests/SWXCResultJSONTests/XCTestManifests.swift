import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SWXCResultJSONTests.allTests),
    ]
}
#endif
