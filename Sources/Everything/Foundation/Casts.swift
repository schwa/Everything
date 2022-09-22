public struct CastError: Error {
    public let message: String?
    public let file: StaticString
    public let line: UInt

    public init(_ message: @autoclosure () -> String? = nil, file: StaticString = #file, line: UInt = #line) {
        self.message = message()
        self.file = file
        self.line = line
    }
}

public func cast <T, T2>(_ object: T, as: T2.Type, _ error: @autoclosure () -> Swift.Error = CastError()) throws -> T2 {
    try (object as? T2).safelyUnwrap(error())
}

public func forceCast <T, T2>(_ object: T, as: T2.Type) -> T2 {
    guard let result = object as? T2 else {
        fatalError("Could not cast.")
    }
    return result
}
