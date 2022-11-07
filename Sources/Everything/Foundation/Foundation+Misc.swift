import Foundation

public extension ClosedRange where Bound: FloatingPoint {
    var isZero: Bool {
        lowerBound == upperBound
    }

    func normalize(_ value: Bound) -> Bound {
        (value - lowerBound) / (upperBound - lowerBound)
    }
}

public extension UnsafeBufferPointer {
    static var elementSize: Int {
        Swift.max(MemoryLayout<Element>.size, 1)
    }

    var byteCount: Int {
        count * UnsafeBufferPointer<Element>.elementSize
    }
}

public func unsafeBitwiseEquality<T>(_ lhs: T, _ rhs: T) -> Bool {
    var lhs = lhs
    var rhs = rhs

    return withUnsafePointers(&lhs, &rhs) {
        memcmp($0, $1, MemoryLayout<T>.size) == 0
    }
}

private func withUnsafePointers<T, R>(_ lhs: inout T, _ rhs: inout T, block: (UnsafePointer<T>, UnsafePointer<T>) throws -> R) rethrows -> R {
    try withUnsafePointer(to: &lhs) { lhs -> R in
        try withUnsafePointer(to: &rhs) { rhs -> R in
            try block(lhs, rhs)
        }
    }
}

public extension FileManager {
    func fileExists(atURL url: URL) -> Bool {
        fileExists(atPath: url.path)
    }
}

public extension FileHandle {
    var url: Result<URL, Error> {
        Result {
            var filePath = Array(repeating: Int8(0), count: Int(PATH_MAX))
            try filePath.withUnsafeMutableBytes { buffer in
                try withPOSIX {
                    fcntl(fileDescriptor, F_GETPATH, buffer.baseAddress!)
                }
            }
            return URL(fileURLWithFileSystemRepresentation: filePath, isDirectory: false, relativeTo: nil)
        }
    }
}

public extension [String: Any] {
    func asPlist() -> String {
        forceTry {
            let d = try PropertyListSerialization.data(fromPropertyList: self, format: .xml, options: 0)
            return String(decoding: d, as: UTF8.self)
        }
    }
}
