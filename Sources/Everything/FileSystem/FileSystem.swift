import Foundation

public struct Directory: Codable, Hashable, Comparable {
    public let path: FSPath

    public init(path: FSPath) {
        self.path = path
    }

    public init(path: String) {
        let path = FSPath(path: path)
        self = Directory(path: path)
    }

    public init(url: URL) {
        let path = FSPath(url: url)
        self = Directory(path: path)
    }

    public var url: URL {
        path.url
    }

    public func hash(into hasher: inout Hasher) {
        url.hash(into: &hasher)
    }

    public static func == (lhs: Directory, rhs: Directory) -> Bool {
        lhs.url.path == rhs.url.path
    }

    public static func < (lhs: Directory, rhs: Directory) -> Bool {
        lhs.url.path < rhs.url.path
    }

    public var exists: Bool {
        path.exists
    }

    public var subdirectories: [Directory] {
        do {
            return try FileManager().contentsOfDirectory(at: path.url, includingPropertiesForKeys: [.isDirectoryKey], options: [])
            .filter {
                let resourceValues = try $0.resourceValues(forKeys: [.isDirectoryKey])
                return resourceValues.isDirectory ?? false
            }
            .map { url -> Directory in
                Directory(url: url)
            }
        }
        catch {
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
        return numberFormatter.string(from: self)!
    }
}

public extension FSPath {
    func has_xattr() -> Bool {
        listxattr(path, nil, 0, XATTR_NOFOLLOW) != 0
    }

    func lsFormat() throws -> String {
        let attributes = try FileManager().attributesOfItem(atPath: path)

        var mode = ""
        switch FileAttributeType(rawValue: attributes[.type] as! String) {
        case .typeDirectory:
            mode += "d"
        case .typeRegular:
            mode += "-"
        case .typeSymbolicLink:
            mode += "l"
        default:
            mode += "?"
        }

        let permissions = attributes[.posixPermissions] as! mode_t
        mode += Permission(rawValue: (permissions & 0o700) >> 6)!.description
        mode += Permission(rawValue: (permissions & 0o070) >> 3)!.description
        mode += Permission(rawValue: (permissions & 0o007) >> 0)!.description
        switch (has_xattr(), false) {
        case (true, _):
            mode += "@"
        case (_, true):
            mode += "+"
        default:
            mode += " "
        }

        let numberOfLinks = (attributes[.referenceCount] as! NSNumber).format(formatWidth: 4, paddingCharacter: " ")
        let ownerName = attributes[.ownerAccountName]!
        let groupName = attributes[.groupOwnerAccountName]!
        let numberOfBytes = (attributes[.size] as! NSNumber).format(formatWidth: 5, paddingCharacter: " ")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yy HH:mm:ss.SSSS" // "Oct  2 19:52"
        let lastModified = dateFormatter.string(from: attributes[.modificationDate] as! Date)
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
        self = try URLBookmark(url: path.url)
    }

    public func resolve() throws -> FSPath {
        var bookmarkDataIsStale = false
        let url = try URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &bookmarkDataIsStale)
        return FSPath(url: url)
    }
}
