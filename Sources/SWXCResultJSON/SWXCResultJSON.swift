
import Foundation
import SWXCActivityLog
import SWXCResult

public final class XCResultJSON {

    public let jsonEncoder = JSONEncoder()

    public init() {
        jsonEncoder.outputFormatting = [.prettyPrinted]
    }

    public func convert(xcresultURL: URL, outputDirURL: URL?) throws {

        let xcresult = try XCResult(bundleURL: xcresultURL)
        let infoURL = xcresult.infoURL
        let infoJSONURL = try urlForOutput(inputURL: infoURL, outputDirURL: outputDirURL)
        let infoJSONData = try jsonEncoder.encode(xcresult.infoPlist)
        try infoJSONData.write(to: infoJSONURL)

        let testSummaries = try xcresult.infoPlist.testSummary(relativeTo: xcresultURL)
        let testSummariesData = try jsonEncoder.encode(testSummaries)
        if let testSummariesURL = xcresult.infoPlist.urlForTestSummary(relativeTo: xcresultURL) {
            let testSummariesJSONURL = try urlForOutput(inputURL: testSummariesURL, outputDirURL: outputDirURL)
            try testSummariesData.write(to: testSummariesJSONURL)
        }

        try xcresult.infoPlist.Actions?.forEach { action in
            try [action.BuildResult, action.ActionResult].compactMap({$0}).forEach {
                try convert(actionResult: $0, xcresultURL: xcresultURL, outputDirURL: outputDirURL)
            }
        }
    }

    public func convert(xcactivitylogURL: URL, xcresultURL: URL?, outputDirURL: URL?) throws {
        let data = try Data(contentsOf: xcactivitylogURL)
        let log = try SLFDecoder().decode(ActivityLog.self, from: data)

        let logJSONURL = try urlForOutput(inputURL: xcactivitylogURL, outputDirURL: outputDirURL)
        let logJSONData = try jsonEncoder.encode(log)
        try logJSONData.write(to: logJSONURL)
    }
}

extension XCResultJSON {
    internal func convert(actionResult: SchemeActionResult, xcresultURL: URL, outputDirURL: URL?) throws {
        if let logPath = actionResult.LogPath {
            let logURL = URL(fileURLWithPath: logPath, relativeTo: xcresultURL)
            try convert(xcactivitylogURL: logURL, xcresultURL: xcresultURL, outputDirURL: outputDirURL)
        }

        if let testSummaryURL = actionResult.urlForTestSummary(relativeTo: xcresultURL) {
            let testSummary = try SchemeActionResultTestSummary.from(contentsOf: testSummaryURL)
            let outputJSONURL = try urlForOutput(inputURL: testSummaryURL, outputDirURL: outputDirURL)
            let outputData = try jsonEncoder.encode(testSummary)
            try outputData.write(to: outputJSONURL)
        }
    }

    internal func urlForOutput(inputURL: URL, outputDirURL: URL?, pathExtension: String = "json", createDirectories: Bool = true) throws -> URL {
        let outputDirURL = outputDirURL ?? inputURL.baseURL ?? inputURL.deletingLastPathComponent()
        let outputURL = inputURL
            .relativeTo(url: outputDirURL)
            .appendingPathExtension(pathExtension)

        if createDirectories {
            try FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(),
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
        }

        return outputURL
    }
}

extension URL {
    internal func relativeTo(url: URL) -> URL {
        if baseURL != nil {
            return url.appendingPathComponent(relativePath)
        }

        let inputComponents = pathComponents
        let baseComponents = url.pathComponents
        guard inputComponents.starts(with: baseComponents) else {
            return self
        }

        let relativeComponents = inputComponents[baseComponents.endIndex...]
        let outputBaseURL = URL(fileURLWithPath: "", isDirectory: true, relativeTo: url)
        return relativeComponents.reduce(outputBaseURL) { (url, path) -> URL in
            return url.appendingPathComponent(path)
        }
    }
}
