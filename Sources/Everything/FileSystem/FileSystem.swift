import Foundation

public struct Directory: Codable, Hashable, Comparable {
    public let path: FSPath

    public init(path: FSPath) {
        self.path = path
    }

    public init(path: String) {
        let path = FSPath(path: path)
        self = Self(path: path)
    }

    public init(url: URL) {
        let path = FSPath(url: url)
        self = Self(path: path)
    }

    public var url: URL {
        path.url
    }

    public func hash(into hasher: inout Hasher) {
        url.hash(into: &hasher)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.url.path == rhs.url.path
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.url.path < rhs.url.path
    }

    public var exists: Bool {
        path.exists
    }

    public var subdirectories: [Self] {
        do {
            return try FileManager().contentsOfDirectory(at: path.url, includingPropertiesForKeys: [.isDirectoryKey], options: [])
                .filter {
                    let resourceValues = try $0.resourceValues(forKeys: [.isDirectoryKey])
                    return resourceValues.isDirectory ?? false
                }
                .map { url -> Self in
                    Self(url: url)
                }
        } catch {
            fatalError("\(error)")
        }
    }

    public func contains(name: String) throws -> Bool {
        let url = path.url.appendingPathComponent(name)
        return try url.checkResourceIsReachable()
    }
}

extension Directory: CustomStringConvertible {
    public var description: String {
        "\(type(of: self))(\(path.path))"
    }
}

private extension NSNumber {
    func format(formatWidth: Int? = nil, paddingCharacter: String? = nil) -> String {
        let numberFormatter = NumberFormatter()
        if let formatWidth {
            numberFormatter.formatWidth = formatWidth
        }
        if let paddingCharacter {
            numberFormatter.paddingCharacter = paddingCharacter
        }
        guard let result = numberFormatter.string(from: self) else {
            fatalError("NumberFormatter failed to format \(self)")
        }
        return result
    }
}

public extension FSPath {
    func has_xattr() -> Bool {
        listxattr(path, nil, 0, XATTR_NOFOLLOW) != 0
    }

    func lsFormat() throws -> String {
        let attributes = try FileManager().attributesOfItem(atPath: path)

        var mode = ""
        guard let typeString = attributes[.type] as? String else {
            fatalError("Missing file type attribute")
        }
        switch FileAttributeType(rawValue: typeString) {
        case .typeDirectory:
            mode += "d"
        case .typeRegular:
            mode += "-"
        case .typeSymbolicLink:
            mode += "l"
        default:
            mode += "?"
        }

        guard let permissions = attributes[.posixPermissions] as? mode_t else {
            fatalError("Missing posix permissions attribute")
        }
        guard let p1 = Permission(rawValue: (permissions & 0o700) >> 6),
              let p2 = Permission(rawValue: (permissions & 0o070) >> 3),
              let p3 = Permission(rawValue: (permissions & 0o007) >> 0) else {
            fatalError("Invalid permission bits")
        }
        mode += p1.description
        mode += p2.description
        mode += p3.description
        switch (has_xattr(), false) {
        case (true, _):
            mode += "@"
        case (_, true):
            mode += "+"
        default:
            mode += " "
        }

        guard let refCount = attributes[.referenceCount] as? NSNumber else {
            fatalError("Missing reference count attribute")
        }
        let numberOfLinks = refCount.format(formatWidth: 4, paddingCharacter: " ")
        guard let ownerName = attributes[.ownerAccountName] else {
            fatalError("Missing owner account name attribute")
        }
        guard let groupName = attributes[.groupOwnerAccountName] else {
            fatalError("Missing group owner account name attribute")
        }
        guard let sizeNumber = attributes[.size] as? NSNumber else {
            fatalError("Missing size attribute")
        }
        let numberOfBytes = sizeNumber.format(formatWidth: 5, paddingCharacter: " ")
        guard let modDate = attributes[.modificationDate] as? Date else {
            fatalError("Missing modification date attribute")
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yy HH:mm:ss.SSSS" // "Oct  2 19:52"
        let lastModified = dateFormatter.string(from: modDate)
        return "\(mode) \(numberOfLinks) \(ownerName)  \(groupName) \(numberOfBytes) \(lastModified) \(path)"
    }
}

public struct Permission: RawRepresentable, CustomStringConvertible {
    public let read: Bool
    public let write: Bool
    public let execute: Bool

    public init?(rawValue: UInt16) {
        read = (rawValue & 0b100) != 0
        write = (rawValue & 0b010) != 0
        execute = (rawValue & 0b001) != 0
    }

    public var rawValue: UInt16 {
        0
    }

    public var description: String {
        (read ? "r" : "-") + (write ? "w" : "-") + (execute ? "x" : "-")
    }
}

public struct URLBookmark: Codable {
    public let bookmarkData: Data

    public init(url: URL) throws {
        bookmarkData = try url.bookmarkData(options: [], includingResourceValuesForKeys: [], relativeTo: nil)
    }

    public init(path: FSPath) throws {
        self = try Self(url: path.url)
    }

    public func resolve() throws -> FSPath {
        var bookmarkDataIsStale = false
        let url = try URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &bookmarkDataIsStale)
        return FSPath(url: url)
    }
}
