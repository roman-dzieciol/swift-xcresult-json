import XCTest
@testable import SWXCResultJSON

final class SWXCResultJSONTests: XCTestCase {
    func testItConvertsToJSON() throws {
        do {
            let url = urlForResultBundles()
            let converter = XCResultJSON()
            try converter.convert(xcresult: url)
        } catch {
            XCTFail("\(error)")
        }
    }

    func urlForResultBundles() -> URL {
        return URL(fileURLWithPath: "\(#file)")
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("ResultBundles")
            .appendingPathComponent("CleanAnalyzeTest.result")
    }

    static var allTests = [
        ("testItConvertsToJSON", testItConvertsToJSON),
    ]
}
