import Foundation

extension FileManager {
    func listxattr(for url: URL) -> [String] {
        let bufferSize = Darwin.listxattr(url.path, nil, 0, 0)
        guard bufferSize > 0 else {
            return []
        }
        let buffer = ContiguousArray<UInt8>(unsafeUninitializedCapacity: bufferSize) { buffer, size in
            buffer.baseAddress!.withMemoryRebound(to: Int8.self, capacity: bufferSize) { pointer in
                size = Darwin.listxattr(url.path, pointer, bufferSize, 0)
            }
        }
        return buffer.split(separator: 0).map { String(bytes: $0, encoding: .utf8)! }
    }

    func xattr(for url: URL, xattr: String) -> Data {
        let bufferSize = getxattr(url.path, xattr, nil, 0, 0, 0)
        let buffer = ContiguousArray<UInt8>(unsafeUninitializedCapacity: bufferSize) { buffer, size in
            size = getxattr(url.path, xattr, buffer.baseAddress, bufferSize, 0, 0)
        }
        return Data(buffer)
    }
}
