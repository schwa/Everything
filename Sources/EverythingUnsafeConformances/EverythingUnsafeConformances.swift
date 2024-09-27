import CoreGraphics
import Foundation
import MultipeerConnectivity

extension CGImageAlphaInfo: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .none:
            return "none"
        case .premultipliedLast:
            return "premultipliedLast"
        case .premultipliedFirst:
            return "premultipliedFirst"
        case .last:
            return "last"
        case .first:
            return "first"
        case .noneSkipLast:
            return "noneSkipLast"
        case .noneSkipFirst:
            return "noneSkipFirst"
        case .alphaOnly:
            return "alphaOnly"
        @unknown default:
            fatalError("Unknown case")
        }
    }
}

extension CGImageByteOrderInfo: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .orderMask:
            return "orderMask"
        case .order16Little:
            return "order16Little"
        case .order32Little:
            return "order32Little"
        case .order16Big:
            return "order16Big"
        case .order32Big:
            return "order32Big"
        case .orderDefault:
            return "orderDefault"
        @unknown default:
            fatalError("Unknown case")
        }
    }
}

extension MCSessionState: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .connected:
            return "connected"
        case .connecting:
            return "connecting"
        case .notConnected:
            return "notConnected"
        @unknown default:
            fatalError("Unknown case")
        }
    }
}

extension Character: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard string.count == 1, let first = string.first else {
            fatalError("Unknown case")
        }
        self = first
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(String(self))
    }
}

extension CharacterSet: @retroactive ExpressibleByExtendedGraphemeClusterLiteral {}
extension CharacterSet: @retroactive ExpressibleByUnicodeScalarLiteral {}
extension CharacterSet: @retroactive ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = CharacterSet(charactersIn: value)
    }
}

extension URL: @retroactive ExpressibleByExtendedGraphemeClusterLiteral {}
extension URL: @retroactive ExpressibleByUnicodeScalarLiteral {}
extension URL: @retroactive ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(string: value)!
    }
}

extension URL: @retroactive ExpressibleByStringInterpolation {
}
