import XCTest
@testable import SWXCResultJSON


final class SWXCResultJSONTests: XCTestCase {

    func testItConvertsToJSON() throws {
        let xcresultURL = urlForResultBundles()
        let outputDirURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        NSLog("Output directory \(outputDirURL)")

        // URLs of converted jsons
        let converter = XCResultJSON()
        try converter.convert(xcresultURL: xcresultURL, outputDirURL: outputDirURL)

        let outputDirURLs = FileManager.default.enumerator(at: outputDirURL, includingPropertiesForKeys: nil, options: [], errorHandler: { (url, error) -> Bool in
            XCTFail("error: \(error) at \(url)")
            return false
        })?.allObjects ?? []

        let jsonURLs: [URL] =  outputDirURLs
            .compactMap({ $0 as? URL })
            .compactMap({ $0.hasDirectoryPath ? nil : $0 })
            .map({ $0.resolvingSymlinksInPath().standardized })
            .map({ ($0 as URL).relativeTo(url: outputDirURL) })

        // All jsons match expected output
        for jsonURL in jsonURLs {
            try diff(url: jsonURL, with: URL(fileURLWithPath: jsonURL.relativePath, relativeTo: xcresultURL))
        }

        // All URLs are present
        let expectedRelativePaths = [
            "./1_Run/build.xcactivitylog.json",
            "./2_Analyze/build.xcactivitylog.json",
            "./3_Test/action.xcactivitylog.json",
            "./3_Test/action_TestSummaries.plist.json",
            "./3_Test/build.xcactivitylog.json",
            "./Info.plist.json",
            "./TestSummaries.plist.json",
        ]
        XCTAssertEqual(Set<String>(jsonURLs.map({ $0.relativePath})), Set<String>(expectedRelativePaths))
    }

    func urlForResultBundles() -> URL {
        return URL(fileURLWithPath: "\(#file)", isDirectory: true)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("ResultBundles")
            .appendingPathComponent("CleanAnalyzeTest.result")
    }

    func diff(url: URL, with otherURL: URL) throws {
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = [
            "git",
            "--no-pager",
            "diff",
            url.standardized.path,
            otherURL.standardized.path
        ]
        var outputData = Data()
        let outputPipe = Pipe()
        outputPipe.fileHandleForReading.readabilityHandler = { _ in
            outputData.append(outputPipe.fileHandleForReading.availableData)
        }
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        try process.run()
        process.waitUntilExit()
        if process.terminationStatus != EXIT_SUCCESS {
            NSLog("diff mismatch: \n\(String(data: outputData, encoding: .utf8) ?? "")")
        }
        XCTAssertEqual(process.terminationStatus, EXIT_SUCCESS)
    }

    static var allTests = [
        ("testItConvertsToJSON", testItConvertsToJSON),
    ]
}

