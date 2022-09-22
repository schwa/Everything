import Darwin
import Foundation

public extension POSIXError {
    static func errno(userInfo: [String: Any] = [:]) -> POSIXError? {
        guard let code = POSIXErrorCode(rawValue: Darwin.errno) else {
            return nil
        }
        return POSIXError(code, userInfo: userInfo)
    }

    init?(_ code: Int32, userInfo: [String: Any] = [:]) {
        guard let code = POSIXErrorCode(rawValue: code) else {
            return nil
        }
        self = POSIXError(code, userInfo: userInfo)
    }
}
