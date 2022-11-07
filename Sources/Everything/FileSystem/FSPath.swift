// swiftlint:disable file_length

import Foundation
#if os(macOS)
    import AppKit
#endif
import CryptoKit
import EverythingHelpers

public struct FSPath: Equatable, Comparable, Hashable {
    public let path: String

    public init(path: String) {
        self.path = path
    }

    public init(url: URL) {
        precondition(url.scheme == "file" || !(url.scheme ?? "").isEmpty && url.path.isEmpty == false, "URL (\(url)) not valid in \(#function)")
        path = url.path
    }

    public var url: URL {
        URL(fileURLWithPath: path)
    }

    public var normalized: FSPath {
        FSPath((path as NSString).expandingTildeInPath)
    }

    public static func == (lhs: FSPath, rhs: FSPath) -> Bool {
        lhs.normalized.path == rhs.normalized.path
    }

    public static func < (lhs: FSPath, rhs: FSPath) -> Bool {
        lhs.normalized.path < rhs.normalized.path
    }
}

public extension FSPath {
    init(_ path: String) {
        self.init(path: path)
    }

    init(_ url: URL) {
        self.init(url: url)
    }
}

// MARK: CustomStringConvertible

extension FSPath: CustomStringConvertible {
    public var description: String {
        path
    }
}

extension FSPath: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        path = try container.decode(String.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(path)
    }
}

// MARK: Path/name manipulation

public extension FSPath {
    var components: [String] {
        (path as NSString).pathComponents
    }

//    var parents: [Path] {
//    }

    var parent: FSPath? {
        FSPath((path as NSString).deletingLastPathComponent)
    }

    var name: String {
        (path as NSString).lastPathComponent
    }

    var pathExtension: String {
        (path as NSString).pathExtension
    }

    var pathExtensions: [String] {
        Array(name.components(separatedBy: ".").suffix(from: 1))
    }

    /// The "stem" of the path is the filename without path extensions
    var stem: String {
        ((path as NSString).lastPathComponent as NSString).deletingPathExtension
    }

    /// Replace the file name portion of a path with name
    func withName(_ name: String) -> FSPath {
        parent! + name
    }

    /// Replace the path extension portion of a path. Note path extensions in iOS seem to refer just to last path extension e.g. "z" of "foo.x.y.z".
    func withPathExtension(_ pathExtension: String) -> FSPath {
        if pathExtension.isEmpty {
            return self
        }
        return withName(stem + "." + pathExtension)
    }

    func withPathExtensions(_ pathExtensions: [String]) -> FSPath {
        let pathExtension = pathExtensions.joined(separator: ".")
        return withPathExtension(pathExtension)
    }

    /// Replace the stem portion of a path: e.g. calling withStem("bar") on /tmp/foo.txt returns /tmp/bar.txt
    func withStem(_ stem: String) -> FSPath {
        (parent! + stem).withPathExtension(pathExtension)
    }

    func pathByExpandingTilde() -> FSPath {
        FSPath((path as NSString).expandingTildeInPath)
    }

    func pathByDeletingLastComponent() -> FSPath {
        FSPath((path as NSString).deletingLastPathComponent)
    }

    var normalizedComponents: [String] {
        var components = components
        if components.last == "/" {
            components = Array(components[0 ..< components.count - 1])
        }
        return components
    }

    func hasPrefix(_ other: FSPath) -> Bool {
        let lhs = normalizedComponents
        let rhs = other.normalizedComponents

        if rhs.count > lhs.count {
            return false
        }
        return Array(lhs[0 ..< rhs.count]) == rhs
    }

    func hasSuffix(_ other: FSPath) -> Bool {
        let lhs = normalizedComponents
        let rhs = other.normalizedComponents
        if rhs.count > lhs.count {
            return false
        }
        return Array(lhs[(lhs.count - rhs.count) ..< lhs.count]) == rhs
    }

    func appendingPathComponent(_ component: FSPath) -> FSPath {
        FSPath(url.appendingPathComponent(component.path))
    }

    func appendingPathComponent(_ component: String) -> FSPath {
        FSPath(url.appendingPathComponent(component))
    }
}

// MARK: Operators

public extension FSPath {
    static func + (lhs: FSPath, rhs: FSPath) -> FSPath {
        lhs.appendingPathComponent(rhs)
    }

    static func / (lhs: FSPath, rhs: FSPath) -> FSPath {
        lhs.appendingPathComponent(rhs)
    }

    static func + (lhs: FSPath, rhs: String) -> FSPath {
        lhs.appendingPathComponent(rhs)
    }

    static func / (lhs: FSPath, rhs: String) -> FSPath {
        lhs.appendingPathComponent(rhs)
    }
}

// MARK: Working Directory

public extension FSPath {
    static var currentDirectory: FSPath {
        get {
            FSPath(FileManager().currentDirectoryPath)
        }
        set {
            FileManager().changeCurrentDirectoryPath(newValue.path)
        }
    }
}

// MARK: File Types

public enum FileType {
    case regular
    case directory
    case symbolicLink
    case socket
    case characterSpecial
    case blockSpecial
    case unknown
}

// MARK: File Attributes

public extension FSPath {
    var exists: Bool {
        FileManager().fileExists(atPath: path)
    }

    var fileType: FileType {
        attributes.fileType
    }

    var isDirectory: Bool {
        fileType == .directory
    }

    var isSymbolicLink: Bool {
        fileType == .symbolicLink
    }

    func chmod(_ permissions: Int) throws {
        try FileManager().setAttributes([FileAttributeKey.posixPermissions: permissions], ofItemAtPath: path)
    }
}

public extension FSPath {
    var attributes: FileAttributes {
        FileAttributes(path)
    }
}

public struct FileAttributes {
    internal let path: String

    internal init(_ path: String) {
        self.path = path
    }

    internal var url: URL {
        URL(fileURLWithPath: path)
    }

    public func getAttributes() throws -> [FileAttributeKey: Any] {
        let attributes = try FileManager().attributesOfItem(atPath: path)
        return attributes
    }

    public func getAttribute<T>(key: FileAttributeKey) throws -> T {
        let attributes = try getAttributes()
        guard let attribute = attributes[key] as? T else {
            throw GeneralError.generic("Could not convert value")
        }
        return attribute
    }

    public var fileType: FileType {
        do {
            let type: FileAttributeType = try getAttribute(key: FileAttributeKey.type)
            switch type {
            case FileAttributeType.typeDirectory:
                return .directory
            case FileAttributeType.typeRegular:
                return .regular
            case FileAttributeType.typeSymbolicLink:
                return .symbolicLink
            case FileAttributeType.typeSocket:
                return .socket
            case FileAttributeType.typeCharacterSpecial:
                return .characterSpecial
            case FileAttributeType.typeBlockSpecial:
                return .blockSpecial
            default:
                return .unknown
            }
        }
        catch {
            return .unknown
        }
    }

    public var isDirectory: Bool {
        fileType == .directory
    }

    public var size: Int {
        forceTry {
            try getAttribute(key: FileAttributeKey.size)
        }
    }

    var permissions: Int {
        forceTry {
            try getAttribute(key: FileAttributeKey.posixPermissions)
        }
    }
}

// Iterating directories

public extension FSPath {
    var children: [FSPath]? {
        guard exists && isDirectory else {
            return nil
        }
        let enumerator = FileManager().enumerator(at: url, includingPropertiesForKeys: nil, options: [.skipsSubdirectoryDescendants, .skipsPackageDescendants], errorHandler: nil)!
        var children: [FSPath] = []
        for url in enumerator {
            let url = url as! URL
            children.append(FSPath(url))
        }
        return children
    }

    // TODO: Need a version we can skip directories and early exit on. Also rethrowing
    func walk(_ closure: (FSPath) -> Void) throws {
        let errorHandler = { (_: URL, _: Swift.Error) -> Bool in
            true
        }

        guard let enumerator = FileManager().enumerator(at: url, includingPropertiesForKeys: nil, options: [], errorHandler: errorHandler) else {
            throw GeneralError.generic("Could not create enumerator")
        }

        for url in enumerator {
            guard let url = url as? URL else {
                throw GeneralError.generic("HMM")
            }
            let path = FSPath(url)
            closure(path)
        }

//        if let mainError {
//            throw mainError
//        }
    }
}

// MARK: Creating, moving, removing etc.

public extension FSPath {
    func createDirectory(withIntermediateDirectories: Bool = false) throws {
        try FileManager().createDirectory(atPath: path, withIntermediateDirectories: withIntermediateDirectories)
    }

    func move(_ destination: FSPath) throws {
        try FileManager().moveItem(at: url, to: destination.url)
    }

    func remove() throws {
        try FileManager().removeItem(atPath: path)
    }
}

// MARK: Glob

public extension FSPath {
    func glob(_ suffix: FSPath? = nil) throws -> [FSPath] {
        let globPath = self / (suffix ?? FSPath(""))

        let error = { (_: UnsafePointer<Int8>?, _: Int32) -> Int32 in
            0
        }
        var globStorage = glob_t()
        let result = glob_b(globPath.path, 0, error, &globStorage)
        guard result == 0 else {
            throw POSIXError(result) ?? GeneralError.unknown
        }
        let paths = (0 ..< globStorage.gl_pathc).map { index -> FSPath in
            let pathPtr = globStorage.gl_pathv[index]
            guard let pathString = String(validatingUTF8: pathPtr!) else {
                fatalError("Could not convert path to utf8 string")
            }
            return FSPath(pathString)
        }
        globfree(&globStorage)
        return paths
    }
}

// MARK: Temporary Directories

public extension FSPath {
    static var temporaryDirectory: FSPath {
        FSPath(NSTemporaryDirectory())
    }

    static func makeTemporaryDirectory(_ temporaryDirectory: FSPath? = nil) throws -> FSPath {
        let temporaryDirectory = (temporaryDirectory ?? self.temporaryDirectory)
        if temporaryDirectory.exists == false {
            try temporaryDirectory.createDirectory(withIntermediateDirectories: true)
        }

        let templateDirectory = temporaryDirectory + "XXXXXXXX"
        var template = templateDirectory.path.cString(using: String.Encoding.utf8)!
        return template.withUnsafeMutableBufferPointer { (buffer: inout UnsafeMutableBufferPointer<Int8>) -> FSPath in
            let pointer = mkdtemp(buffer.baseAddress)
            let pathString = String(validatingUTF8: pointer!)!
            let path = FSPath(pathString)
            return path
        }
    }

    static func withTemporaryDirectory<R>(_ temporaryDirectory: FSPath? = nil, closure: (FSPath) throws -> R) throws -> R {
        let path = try makeTemporaryDirectory(temporaryDirectory)
        defer {
            forceTry {
                try path.remove()
            }
        }
        return try closure(path)
    }
}

// MARK: Well-Known/Special Directories

public extension FSPath {
    static var applicationSpecificSupportDirectory: FSPath {
        let bundle = Bundle.main
        let bundleIdentifier = bundle.bundleIdentifier!
        let path = applicationSupportDirectory! + bundleIdentifier
        if path.exists == false {
            forceTry {
                try path.createDirectory(withIntermediateDirectories: true)
            }
        }
        return path
    }

    static func specialDirectory(_ directory: FileManager.SearchPathDirectory, inDomain domain: FileManager.SearchPathDomainMask = .userDomainMask, appropriateForURL url: URL? = nil, create shouldCreate: Bool = true) throws -> FSPath {
        let url = forceTry {
            try FileManager().url(for: directory, in: domain, appropriateFor: url, create: shouldCreate)
        }
        return FSPath(url)
    }

    static var libraryDirectory: FSPath? {
        try? FSPath.specialDirectory(.libraryDirectory)
    }

    static var applicationSupportDirectory: FSPath? {
        try? FSPath.specialDirectory(.applicationSupportDirectory)
    }

    static var documentDirectory: FSPath? {
        try? FSPath.specialDirectory(.documentDirectory)
    }
}

// MARK: -

// MARK: -

extension FSPath: ExpressibleByUnicodeScalarLiteral, ExpressibleByStringLiteral, ExpressibleByExtendedGraphemeClusterLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

#if os(macOS)
    public extension FSPath {
        var icon: NSImage {
            NSWorkspace.shared.icon(forFile: path)
        }
    }
#endif

// MARK: -

public extension FSPath {
    init(fileDescriptor fd: Int32) throws {
        var buffer = [Int8](repeating: 0, count: Int(PATH_MAX))
        buffer.withUnsafeMutableBufferPointer { buffer in
            if fcntl_FGETPATH(fd, buffer.baseAddress!) == -1 {
                fatalError("fcntl_FGETPATH failed")
            }
        }
        let path = String(cString: buffer)
        self = FSPath(path)
    }
}

public extension FSPath {
    init<C>(components: C) where C: Collection, C.Element: StringProtocol {
        if components.first == "/" {
            let s = components.dropFirst().joined(separator: "/")
            self = FSPath(path: "/" + s)
        }
        else {
            let s = components.joined(separator: "/")
            self = FSPath(path: s)
        }
    }
}

// MARK: Deprecated but hanging around!

@available(*, deprecated, message: "Rewrite this as FSPath.open() or FSPath.content.data or use the async .lines, .bytes")
public extension FSPath {
    var data: Data {
        get throws {
            try Data(contentsOf: url)
        }
    }

    var sha256: SHA256Digest {
        get throws {
            SHA256.hash(data: try data)
        }
    }
}

public extension FSPath {
    @available(*, deprecated, message: "Rewrite this with better otions")
    func createFile() throws {
        if FileManager.default.createFile(atPath: path, contents: nil, attributes: nil) == false {
            throw GeneralError.generic("Could not create file")
        }
    }

    @available(*, deprecated, message: "Rewrite this with better otions")
    func read() throws -> String {
        try String(contentsOf: url)
    }

    @available(*, deprecated, message: "Rewrite this with better otions")
    func write(_ string: String, encoding: String.Encoding = .utf8) throws {
        try string.write(toFile: path, atomically: true, encoding: encoding)
    }
}

@available(*, deprecated, message: "Better if we exposed a 'directoryContents'")
extension FSPath: Sequence {
    public class Iterator: IteratorProtocol {
        let enumerator: NSEnumerator

        init(path: FSPath) {
            enumerator = FileManager().enumerator(at: path.url, includingPropertiesForKeys: nil, options: [.skipsSubdirectoryDescendants, .skipsPackageDescendants], errorHandler: nil)!
        }

        public func next() -> FSPath? {
            guard let url = enumerator.nextObject() as? URL else {
                return nil
            }
            return FSPath(url)
        }
    }

    public func makeIterator() -> Iterator {
        Iterator(path: self)
    }
}

public extension FSPath {
    var displayName: String {
        FileManager().displayName(atPath: path)
    }
}
