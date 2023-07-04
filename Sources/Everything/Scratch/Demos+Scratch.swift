import Foundation
import SwiftUI
#if os(macOS)
    import AppKit
#elseif os(iOS) || os(tvOS)
    import UIKit
#endif
import Combine
import CoreGraphics
import MetalKit

public extension Collection where Element: Identifiable {
    func first(identifiedBy id: Element.ID) -> Element? {
        first { $0.id == id }
    }

    func firstIndex(identifiedBy id: Element.ID) -> Index? {
        firstIndex { $0.id == id }
    }
}

// TODO: Move
public extension Image {
    init(cgImage: CGImage) {
        #if os(macOS)
            let nsImage = NSImage(cgImage: cgImage)
            self = Image(nsImage: nsImage)
        #else
            let uiImage = UIImage(cgImage: cgImage)
            self = Image(uiImage: uiImage)
        #endif
    }
}

// MARK: Metal

public extension IntSize {
    func contains(_ point: IntPoint) -> Bool {
        point.x >= 0 && point.x < width && point.y >= 0 && point.y < height
    }
}

public extension Array {
    mutating func mutate(_ block: (inout Element) throws -> Void) rethrows {
        try indexed().forEach { index, element in
            var element = element
            try block(&element)
            self[index] = element
        }
    }

    func mutated(_ block: (inout Element) throws -> Void) rethrows -> [Element] {
        try map { element in
            var element = element
            try block(&element)
            return element
        }
    }
}

public extension OptionSet {
    static func | (lhs: Self, rhs: Self) -> Self {
        lhs.union(rhs)
    }
}

public extension Text {
    static func lorem() -> Self {
        // swiftlint:disable line_length
        Text("""
        Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
        """)
        // swiftlint:enable line_length
    }
}

public extension Collection {
    func counted() -> Self {
        print("\(count)")
        return self
    }
}

// TODO: Move (maybe put in Rect)
public extension CGRect {
    init(_ scalars: [CGFloat]) {
        assert(!scalars.isEmpty)
        self = CGRect(x: scalars[0], y: scalars[1], width: scalars[2], height: scalars[3])
    }

    static func * (lhs: CGRect, rhs: CGSize) -> CGRect {
        CGRect(x: lhs.origin.x * rhs.width, y: lhs.origin.y * rhs.height, width: lhs.size.width * rhs.width, height: lhs.size.height * rhs.height)
    }

    static func / (lhs: CGRect, rhs: CGSize) -> CGRect {
        CGRect(x: lhs.origin.x / rhs.width, y: lhs.origin.y / rhs.height, width: lhs.size.width / rhs.width, height: lhs.size.height / rhs.height)
    }
}

// TODO: Move
public extension CGSize {
    init(_ size: IntSize) {
        self = CGSize(width: CGFloat(size.width), height: CGFloat(size.height))
    }
}

public extension CGRect {
    func unitPoint(_ p: CGPoint) -> CGPoint {
        origin + CGPoint(size) * p
    }
}

// TODO: Move
public extension View {
    func infiniteFrame() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

public extension RegularExpression.Match {
    struct CaptureGroups {
        public let match: RegularExpression.Match

        public subscript(index: Int) -> String {
            let range = match.result.range(at: index)
            let r2 = Range(range, in: match.string)!
            return String(match.string[r2])
        }

        public subscript(name: String) -> String {
            let range = match.result.range(withName: name)
            let r2 = Range(range, in: match.string)!
            return String(match.string[r2])
        }
    }

    var groups: CaptureGroups {
        CaptureGroups(match: self)
    }
}

public extension UInt8 {
    init(character: Character) {
        assert(character.utf8.count == 1)
        self = character.utf8.first!
    }
}

public extension Character {
    init(utf8: UInt8) {
        self = Character(UnicodeScalar(utf8))
    }
}
