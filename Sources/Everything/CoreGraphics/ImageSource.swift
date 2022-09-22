import Foundation
import ImageIO
import UniformTypeIdentifiers

public struct ImageSource {
    public enum ImageSourceError: Error {
        case unknown
    }

    let imageSource: CGImageSource

    public init(data: Data) throws {
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
            throw ImageSourceError.unknown
        }
        self.imageSource = imageSource
    }

    public init(url: URL) throws {
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            throw ImageSourceError.unknown
        }
        self.imageSource = imageSource
    }

    public var count: Int {
        CGImageSourceGetCount(imageSource)
    }

    public func image(at index: Int) throws -> CGImage {
        guard let image = CGImageSourceCreateImageAtIndex(imageSource, index, nil) else {
            throw ImageSourceError.unknown
        }
        return image
    }

    public func properties(at index: Int) throws -> [String: Any] {
        CGImageSourceCopyPropertiesAtIndex(imageSource, index, nil) as! [String: Any]
    }
}

public extension ImageSource {
    init(named name: String, bundle: Bundle = Bundle.main) throws {
        guard let url = bundle.url(forResource: name, withExtension: "png") else { // TODO
            fatalError()
        }
        self = try ImageSource(url: url)
    }
}

#if os(macOS)
import AppKit

public extension CGImage {
    static func image(contentsOf url: URL) throws -> CGImage {
        let nsImage = NSImage(contentsOf: url)! // TODO: Bang
        let cgImage = nsImage.cgImage
        return cgImage
    }
}
#elseif os(iOS)
import UIKit

public extension CGImage {
    static func image(contentsOf url: URL) throws -> CGImage {
        // TODO
        unimplemented()
    }
}
#endif // os(macOS)
