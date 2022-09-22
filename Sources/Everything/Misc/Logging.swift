import Combine
import Foundation
import os.log

// https://developer.apple.com/documentation/os/logging/generating_log_messages_from_your_code

public extension Error {
    func log(level: OSLogType = .error, file: String = #file, line: Int = #line, column: Int = #column, function: String = #function, dsohandle: UnsafeRawPointer = #dsohandle) {
        let logger = Logger()
        logger.log(level: level, "\(String(describing: self))")
    }
}

public func warning(_ message: @autoclosure () -> String? = Optional.none, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
    warning(false, message(), file: file, function: function, line: line)
}

public func warning(_ closure: @autoclosure () -> Bool = false, _ message: @autoclosure () -> String? = Optional.none, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
    guard closure() == false else {
        return
    }

    let logger = Logger()
    if let message = message() {
        logger.debug("\(message)")
    }
    else {
        logger.debug("Warning! \(file)#\(line)")
    }
}
