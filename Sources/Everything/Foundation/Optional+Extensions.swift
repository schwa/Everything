import Foundation

public extension Optional {
    @discardableResult
    func safelyUnwrap(_ error: @autoclosure () -> Swift.Error) throws -> Wrapped {
        switch self {
        case .none:
            throw error()
        case .some(let wrapped):
            return wrapped
        }
    }

    func forceUnwrap(_ message: @autoclosure () -> String = String(), file: StaticString = #file, line: UInt = #line) -> Wrapped {
        switch self {
        case .none:
            fatalError(message(), file: file, line: line)
        case .some(let wrapped):
            return wrapped
        }
    }
}

public extension Optional where Wrapped: Collection {
    func nilify() -> Wrapped? {
        switch self {
        case .some(let value):
            if value.isEmpty {
                return nil
            }
            else {
                return value
            }
        case .none:
            return nil
        }
    }
}
