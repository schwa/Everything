import Foundation

#if os(macOS)
    public func makeRamDisk(size: UInt64, name: String) throws -> URL {
        let mountPoint = URL(fileURLWithPath: "/Volumes/\(name)")
        if FileManager().fileExists(atPath: mountPoint.path) {
            unimplemented()
        }
        let size = size / 512
        let device = try Process.checkOutputString(launchPath: "/usr/bin/hdiutil", arguments: shlex("attach -nomount ram://\(size)")).trimmingCharacters(in: .whitespaces)
        print(try Process.checkOutputString(launchPath: "/usr/sbin/diskutil", arguments: shlex("erasevolume HFS+ \(name) \(device)")))
        if !FileManager().fileExists(atPath: mountPoint.path) {
            unimplemented()
        }
        return mountPoint
    }
#endif

public struct Platform: Hashable {
    let rawValue: String
    public static let macOS = Platform(rawValue: "macOS")
    public static let iOS = Platform(rawValue: "iOS")
    public static let tvOS = Platform(rawValue: "tvOS")
    public static let watchOS = Platform(rawValue: "watchOS")
    public static let linux = Platform(rawValue: "linux")

    #if os(macOS)
        public static let current = macOS
    #elseif os(iOS) || os(tvOS)
        public static let current = iOS
    #else
        public static let current: Platform = {
            fatalError("Unknown platform")
        }()
    #endif
}

public func cast<T>(_ value: Any, as: T.Type) throws -> T {
    guard let value = value as? T else {
        throw GeneralError.valueConversionFailure
    }
    return value
}
