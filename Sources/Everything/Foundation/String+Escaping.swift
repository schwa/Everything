import Foundation

public extension String {
    var escaped: String {
        unicodeScalars.map {
            String($0).isPrintable ? String($0) : $0.escapedString
        }
        .joined()
    }
}

public extension UnicodeScalar {
    var escapedString: String {
        switch value {
        case 0x00:
            return "\\0"
        case 0x09:
            return "\\t"
        case 0x0A:
            return "\\n"
        case 0x0D:
            return "\\r"
        case 0x22:
            return "\\\""
        case 0x27:
            return "\\'"
        case 92:
            return "\\\\"
        case 32 ..< 127:
            return String(self)

        default:
            return "\\u{\(String(value, radix: 16))}"
        }
    }
}
