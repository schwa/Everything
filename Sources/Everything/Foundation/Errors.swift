import Foundation
import os

public struct AnnotatedError: Swift.Error {
    let error: Swift.Error
    let message: String
}

public struct UndefinedError: Error {
    public let message: String?
    public let file: StaticString
    public let line: UInt

    public init(_ message: @autoclosure () -> String? = nil, file: StaticString = #file, line: UInt = #line) {
        self.message = message()
        self.file = file
        self.line = line
    }
}

// MARK: -

public enum GeneralError: Swift.Error {
    case generic(String)
    case dispatchIO(Int32, String)
    case illegalValue
    case unhandledSystemFailure
    case valueConversionFailure
    case missingValue
    case unimplemented
    case unknown
}

extension GeneralError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .generic(let string):
            return string

        case .dispatchIO(let code, let string):
            return "\(code) \(string)"
        case .illegalValue:
            return "illegalValue"
        case .unhandledSystemFailure:
            return "unhandledSystemFailure"
        case .valueConversionFailure:
            return "valueConversionFailure"
        case .missingValue:
            return "missingValue"
        case .unimplemented:
            return "unimplemented"
        case .unknown:
            return "unknown"
        }
    }
}

// MARK: -

public func unimplemented(_ message: @autoclosure () -> String = String(), file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError(message(), file: file, line: line)
}

public func uncallable(_ message: @autoclosure () -> String = String(), file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError(message(), file: file, line: line)
}

// MARK: -

public func generalError(_ error: GeneralError, file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError(error, file: file, line: line)
}

public func fatalError(_ error: Error, file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError(String(describing: error), file: file, line: line)
}

// MARK: -

public func makeOSStatusError(_ status: some BinaryInteger, description: String? = nil) -> Swift.Error {
    var userInfo: [String: String]?

    if let description {
        userInfo = [NSLocalizedDescriptionKey: description]
    }

    return NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: userInfo)
}

public func withNoOutput<R>(_ block: () throws -> R) throws -> R {
    fflush(stderr)
    let savedStdOut = dup(fileno(stdout))
    let savedStdErr = dup(fileno(stderr))

    var fd: [Int32] = [0, 0]
    var err = pipe(&fd)
    guard err >= 0 else {
        throw NSError(domain: NSPOSIXErrorDomain, code: Int(err), userInfo: nil)
    }

    err = dup2(fd[1], fileno(stdout))
    guard err >= 0 else {
        unimplemented()
    }

    err = dup2(fd[1], fileno(stderr))
    guard err >= 0 else {
        unimplemented()
    }

    defer {
        fflush(stderr)
        var err = dup2(savedStdErr, fileno(stderr))
        guard err >= 0 else {
            unimplemented()
        }
        err = dup2(savedStdOut, fileno(stdout))
        guard err >= 0 else {
            unimplemented()
        }

        assert(err >= 0)
    }

    return try block()
}

public func assertChange<R>(value: @autoclosure () -> some Equatable, transaction: () throws -> R) rethrows -> R {
    let before = value()
    defer {
        let after = value()
        assert(before != after)
    }
    return try transaction()
}

public func withPOSIX(_ block: () -> Int32) throws {
    let result = block()
    if result < 0 {
        throw POSIXError(POSIXErrorCode(rawValue: errno)!)
    }
}

// MARK: -

public func tryElseLog<R>(_ type: OSLogType = .error, _ message: @autoclosure () -> String = String(), _ block: () throws -> R) -> R? {
    do {
        return try block()
    } catch {
        let message = message()
        if message.isEmpty {
            os_log(type, "%s", String(describing: error))
        } else {
            os_log(type, "%s: %s", message, String(describing: error))
        }
        return nil
    }
}

public func forceTry<Result>(_ message: @autoclosure () -> String = String(), file: StaticString = #file, line: UInt = #line, closure: () throws -> Result) -> Result {
    do {
        return try closure()
    } catch {
        fatalError(message(), file: file, line: line)
    }
}
