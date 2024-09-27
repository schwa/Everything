import SwiftUI

public extension Image {
    init(data: Data) throws {
        #if os(macOS)
        guard let nsImage = NSImage(data: data) else {
            throw GeneralError.generic("Could not load image")
        }
        self = Image(nsImage: nsImage)
        #else
        guard let uiImage = UIImage(data: data) else {
            throw GeneralError.generic("Could not load image")
        }
        self = Image(uiImage: uiImage)
        #endif
    }
}

public extension Image {
    init(url: URL) throws {
        #if os(macOS)
        guard let nsImage = NSImage(contentsOf: url) else {
            throw GeneralError.generic("Could not load image")
        }
        self = Image(nsImage: nsImage)
        #else
        guard let uiImage = UIImage(contentsOfFile: url.path) else {
            throw GeneralError.generic("Could not load image")
        }
        self = Image(uiImage: uiImage)
        #endif
    }
}

public extension Image {
    init(cgImage: CGImage) {
        #if os(macOS)
        let nsImage = NSImage(cgImage: cgImage, size: CGSize(width: cgImage.width, height: cgImage.height))
        self = Image(nsImage: nsImage)
        #else
        let uiImage = UIImage(cgImage: cgImage)
        self = Image(uiImage: uiImage)
        #endif
    }
}
