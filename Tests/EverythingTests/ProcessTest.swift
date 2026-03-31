#if os(macOS)

    @testable import Everything
    import XCTest

    class ProcessTest: XCTestCase {
        func test1() throws {
            let result = try Process.checkOutputString(launchPath: "/bin/echo", arguments: ["-n", "Hello world"])
            XCTAssertEqual(result, "Hello world")
        }

        func test2() throws {
            XCTAssertThrowsError(try Process.checkOutputString(launchPath: "/usr/bin/false", arguments: []))
        }

        func test4() throws {
            let result = try Process.checkOutput(launchPath: "/usr/bin/true", arguments: [])
            XCTAssertEqual(result.terminationStatus, 0)
        }

        func test5() throws {
            let tempPath = NSTemporaryDirectory() + "XXXXXXXX.txt"
            let (output, filePath) = try FileHandle.temp(template: tempPath, suffixLength: 4)
            defer {
                // Clean up temp file
                try? FileManager.default.removeItem(atPath: filePath)
            }
            let result = try Process.call(launchPath: "/bin/echo", arguments: ["-n", "Hello world"], standardOutput: .fileHandle(output))
            XCTAssertEqual(result.terminationStatus, 0)
            try output.seek(toOffset: 0)
            let s = try String(decoding: output.readToEnd()!, as: UTF8.self)
            XCTAssertEqual(s, "Hello world")
        }

//        func test6() throws {
//            let result = try Process.checkOutput(launchPath: "/usr/bin/python3", arguments: ["-c", "import sys; sys.stderr.write('Hello world')"])
//            XCTAssertEqual(result.terminationStatus, 0)
//            XCTAssertEqual(try result.standardError!.read().toString(), "Hello world")
//        }

//        func test7() throws {
//            let result = try Process.checkOutput(launchPath: "/usr/bin/python3", arguments: ["-c", "import sys; sys.stderr.write('Hello'); sys.stderr.write(' world')"], options: .combinedOutput)
//            XCTAssertEqual(result.terminationStatus, 0)
//            XCTAssertEqual(try result.standardError!.read().toString(), "Hello world")
//        }
    }

    extension Data {
        func toString() -> String {
            String(decoding: self, as: UTF8.self)
        }
    }

    extension FileHandle {
        static func temp(template: String, suffixLength: Int) throws -> (FileHandle, String) {
            var template = template.utf8CString
            return template.withUnsafeMutableBufferPointer { buffer in
                let fd = mkstemps(buffer.baseAddress, Int32(suffixLength))
                guard fd > 0 else {
                    fatalError("mkstemp failed")
                }
                let handle = FileHandle(fileDescriptor: fd, closeOnDealloc: true)
                let path = String(cString: buffer.baseAddress!)
                return (handle, path)
            }
        }
    }

#endif
