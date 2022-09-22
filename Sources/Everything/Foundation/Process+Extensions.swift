// swiftlint:disable indentation_width
// swiftlint:disable line_length

#if os(macOS)

    import Combine
    import Foundation

    public extension Process {
        enum ProcessError: Swift.Error {
            case resourceNotReachable
            case invalidShell
            case encodingError
            case terminationStatus(Int32)
            case cannotReadOutput
        }

        enum Input {
            case pipe(Pipe)
            case fileHandle(FileHandle)
            case file(URL)
            case data(Data)
            case string(String)

            internal func any() throws -> Any {
                switch self {
                case .pipe(let pipe):
                    return pipe
                case .fileHandle(let fileHandle):
                    return fileHandle
                case .file(let url):
                    return try FileHandle(forReadingFrom: url)
                case .data(let data):
                    let pipe = Pipe()
                    pipe.fileHandleForWriting.write(data)
                    pipe.fileHandleForWriting.closeFile()
                    return pipe
                case .string(let string):
                    return try Input.data(string.data(using: .utf8)!).any()
                }
            }
        }

        enum Output {
            case pipe(Pipe)
            case fileHandle(FileHandle)

            internal func any() throws -> Any {
                switch self {
                case .pipe(let pipe):
                    return pipe
                case .fileHandle(let fileHandle):
                    return fileHandle
                }
            }

            public func read() throws -> Data {
                guard case .pipe(let pipe) = self else {
                    throw ProcessError.cannotReadOutput
                }
                return pipe.fileHandleForReading.readDataToEndOfFile()
            }

            public static var pipe: Self {
                .pipe(Pipe())
            }
        }

        struct Options: OptionSet {
            public let rawValue: Int

            public static let `default`: Options = []
            public static let useShell = Options(rawValue: 1 << 0)
            public static let combinedOutput = Options(rawValue: 2 << 0)

            public init(rawValue: Int) {
                self.rawValue = rawValue
            }
        }

// struct LaunchParameters {
//     let launchPath: String
//     let arguments: [String]
//     let options: Options
//     let standardInput: Input?
//     let standardOutput: Output?
//     let standardError: Output?
//     let currentDirectoryURL: URL?
// }

        struct Result {
            public let terminationStatus: Int32
            public let standardOutput: Output?
            public let standardError: Output?
        }

        static func prepare(launchPath: String, arguments: [String], options: Options = .default, standardInput: Input? = nil, standardOutput: Output? = nil, standardError: Output? = nil, currentDirectoryURL: URL? = nil) throws -> Process {
            if try currentDirectoryURL?.checkResourceIsReachable() == false {
                throw ProcessError.resourceNotReachable
            }
            let process = Process()
            process.standardInput = try standardInput?.any()
            process.standardOutput = try standardOutput?.any()
            process.standardError = try standardError?.any()
            if options.contains(.useShell) {
                guard let shell = ProcessInfo.processInfo.environment["SHELL"] else {
                    throw ProcessError.invalidShell
                }
                process.launchPath = shell
                func escape(string: String) -> String {
                    // Note: Replacing spaces with escaped spaces is _not_ rigorous enough.
                    string.replacingOccurrences(of: " ", with: "\\ ")
                }
                let argumentsString = ([launchPath] + arguments.map(escape)).joined(separator: " ")
                process.arguments = ["--login", "-c", argumentsString]
            }
            else {
                process.launchPath = launchPath
                process.arguments = arguments
            }
            if let currentDirectoryURL {
                process.currentDirectoryURL = currentDirectoryURL
            }
            return process
        }

        static func call(launchPath: String, arguments: [String], options: Options = .default, standardInput: Input? = nil, standardOutput: Output? = nil, standardError: Output? = nil, currentDirectoryURL: URL? = nil) throws -> Result {
            assert(!options.contains(.combinedOutput), "call cannot process .combinedOutput")

            let process = try prepare(launchPath: launchPath, arguments: arguments, options: options, standardInput: standardInput, standardOutput: standardOutput, standardError: standardError, currentDirectoryURL: currentDirectoryURL)
            try process.run()
            process.waitUntilExit()
            let result = Result(terminationStatus: process.terminationStatus, standardOutput: standardOutput, standardError: standardError)
            return result
        }

        static func checkOutput(launchPath: String, arguments: [String], options: Options = .default, standardInput: Input? = nil, standardError: Output? = nil, currentDirectoryURL: URL? = nil) throws -> Result {
            let standardOutput = Output.pipe(Pipe())
            var standardError: Output! = standardError
            if standardError == nil {
                if options.contains(.combinedOutput) {
                    standardError = standardOutput
                }
                else {
                    standardError = .pipe(Pipe())
                }
            }

            let options = options.subtracting(.combinedOutput)

            let result = try call(launchPath: launchPath, arguments: arguments, options: options, standardInput: standardInput, standardOutput: standardOutput, standardError: standardError, currentDirectoryURL: currentDirectoryURL)

            if result.terminationStatus != 0 {
                warning("\(result)")
                throw ProcessError.terminationStatus(result.terminationStatus)
            }

            return result
        }
    }

    public extension Process {
        static func checkOutputString(launchPath: String, arguments: [String], options: Options = .default, standardInput: Input? = nil, standardError: Output? = nil, currentDirectoryURL: URL? = nil) throws -> String {
            let result = try checkOutput(launchPath: launchPath, arguments: arguments, options: options, standardInput: standardInput, standardError: standardError, currentDirectoryURL: currentDirectoryURL)
            let data = try result.standardOutput!.read()
            if data.isEmpty {
                return ""
            }
            guard let string = String(data: data, encoding: .utf8) else {
                throw ProcessError.encodingError
            }
            return string
        }

        static func checkOutputLines(launchPath: String, arguments: [String], options: Options = .default, standardInput: Input? = nil, standardOutput: Output? = nil, standardError: Output? = nil, currentDirectoryURL: URL? = nil) throws -> [String] {
            let string = try checkOutputString(launchPath: launchPath, arguments: arguments, options: options, standardInput: standardInput, standardError: standardError, currentDirectoryURL: currentDirectoryURL)
            let lines = string.components(separatedBy: .newlines)
            return lines
        }

        static func osascript(script: String) throws -> String {
            try checkOutputString(launchPath: "/usr/bin/osascript", arguments: ["-e", script])
        }
    }

    internal extension Pipe {
        func readString() -> String {
            let data = fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8)!
        }
    }

    extension Process.Result: CustomStringConvertible {
        public var description: String {
            "Result(terminationStatus: \(terminationStatus), standardOutput: \(String(describing: standardOutput)), standardError: \(String(describing: standardError)))"
        }
    }

    // TODO:

    public extension Process {
        static func publisher(launchPath: String, arguments: [String], options: Options = .default, standardInput: Input? = nil, standardOutput: Output? = nil, standardError: Output? = nil, currentDirectoryURL: URL? = nil) -> AnyPublisher<Result, Error> {
            let deferredFuture = Deferred {
                Future<Process.Result, Error> { promise in
                    do {
                        let process = try prepare(launchPath: launchPath, arguments: arguments, options: options, standardInput: standardInput, standardOutput: standardOutput, standardError: standardError, currentDirectoryURL: currentDirectoryURL)
                        process.terminationHandler = { process in
                            let result = Result(terminationStatus: process.terminationStatus, standardOutput: standardOutput, standardError: standardError)
                            promise(.success(result))
                        }
                        try process.run()
                    }
                    catch {
                        promise(.failure(error))
                    }
                }
            }
            return deferredFuture.eraseToAnyPublisher()
        }
    }

#endif
