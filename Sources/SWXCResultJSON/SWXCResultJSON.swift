
import Foundation
import SWXCActivityLog
import SWXCResult

public final class XCResultJSON {

    public let jsonEncoder = JSONEncoder()

    public init() {
        jsonEncoder.outputFormatting = [.prettyPrinted]
    }

    public func convert(xcresult url: URL) throws {
        let xcresult = try XCResult(bundleURL: url)
        let infoJSONURL = xcresult.infoURL.appendingPathExtension("json")
        let infoJSONData = try jsonEncoder.encode(xcresult.infoPlist)
        try infoJSONData.write(to: infoJSONURL)

        let testSummaries = try xcresult.infoPlist.testSummary(relativeTo: url)
        let testSummariesData = try jsonEncoder.encode(testSummaries)
        let testSummariesJSONURL = try xcresult.infoPlist.urlForTestSummary(relativeTo: url).appendingPathExtension("json")
        try testSummariesData.write(to: testSummariesJSONURL)

        try xcresult.infoPlist.Actions?.forEach { action in
            try [action.BuildResult, action.ActionResult].compactMap({$0}).forEach {
                try convert(result: $0, baseURL: url)
            }
        }
    }

    public func convert(result: SchemeActionResult, baseURL: URL) throws {
        if let logPath = result.LogPath {
            let logURL = baseURL.appendingPathComponent(logPath)
            try convert(xcactivitylog: logURL)
        }

        if let testSummaryURL = result.urlForTestSummary(relativeTo: baseURL) {
            let testSummary = try SchemeActionResultTestSummary.from(contentsOf: testSummaryURL)
            let outputJSONURL = testSummaryURL.appendingPathExtension("json")
            let outputData = try jsonEncoder.encode(testSummary)
            try outputData.write(to: outputJSONURL)
        }
    }

    public func convert(xcactivitylog url: URL) throws {
        let data = try Data(contentsOf: url)
        let log = try SLFDecoder().decode(ActivityLog.self, from: data)

        let logJSONURL = url.appendingPathExtension("json")
        let logJSONData = try jsonEncoder.encode(log)
        try logJSONData.write(to: logJSONURL)
    }

}
