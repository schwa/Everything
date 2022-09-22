import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        [
            testCase(SwiftParsingTests.allTests),
        ]
    }
#endif
