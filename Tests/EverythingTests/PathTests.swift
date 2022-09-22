@testable import Everything
import Foundation
import XCTest

let githubActions = ProcessInfo.processInfo.environment["GITHUB_ACTIONS"] != nil

class PathTests: XCTestCase {
    func testInit() {
        if githubActions {
            return
        }

        do {
            let path = FSPath("/tmp")
            XCTAssertEqual(path.path, "/tmp")
        }
        do {
            let path = FSPath(URL(fileURLWithPath: "/tmp"))
            XCTAssertEqual(path.path, "/tmp")
        }
//        do {
//            let path = FSPath(URL(string: "http://google.com")!)
//            XCTAssertNil(path)
//        }
        do {
            let path = FSPath(URL(fileURLWithPath: "/tmp"))
            XCTAssertEqual(path.path, "/tmp")
        }
        do {
            let path = FSPath("~")
            XCTAssertEqual(path.normalized.path, ("~" as NSString).expandingTildeInPath)
        }
        do {
            let path = FSPath("/tmp")
            XCTAssertEqual(path.components.count, 2)
            XCTAssertEqual(path.components[0], "/")
            XCTAssertEqual(path.components[1], "tmp")
            XCTAssertEqual(path.parent!, FSPath("/"))
        }
        do {
            XCTAssertTrue(FSPath("/") < FSPath("/tmp"))
        }
        do {
            let path = FSPath("foo.bar.zip")
            XCTAssertEqual(path.pathExtensions.count, 2)
            XCTAssertEqual(path.pathExtensions[0], "bar")
            XCTAssertEqual(path.pathExtensions[1], "zip")
        }
//        do {
//            let path = Path("/tmp/foo.bar.zip")
//            XCTAssertEqual(path.stem, "foo")
//        }
        do {
            let path = FSPath("/tmp/foo.bar.zip").withName("xyzzy")
            XCTAssertEqual(path.path, "/tmp/xyzzy")
        }
//        do {
//            let path = Path("/tmp/foo.bar.zip").withPathExtension(".bz2")
//            XCTAssertEqual(String(path), "/tmp/foo.bar.bz2")
//        }
        do {
            let path = FSPath("/tmp/foo.bar.zip").withStem("xyzzy")
            XCTAssertEqual(path.path, "/tmp/xyzzy.zip")
        }
    }

    // TODO: Failing test
//    func test1() {
//        try! FSPath.withTemporaryDirectory {
//            directory in
//
//            let file = directory + "test.txt"
//            XCTAssertFalse(file.exists)
//
//            XCTAssertEqual(file.name, "test.txt")
//            XCTAssertEqual(file.pathExtension, "txt")
//
//            try file.createFile()
//            XCTAssertTrue(file.exists)
//        }
//    }
}
