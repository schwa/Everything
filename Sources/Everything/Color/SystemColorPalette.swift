import CoreGraphics

#if os(macOS)
    import AppKit
#elseif os(iOS) || os(tvOS)
    import UIKit
#endif

public protocol SystemColorPalette {
    associatedtype SystemColor

    static var clear: SystemColor { get }
    static var white: SystemColor { get }
    static var black: SystemColor { get }
    static var red: SystemColor { get }
    static var green: SystemColor { get }
    static var blue: SystemColor { get }
    static var magenta: SystemColor { get }
    static var yellow: SystemColor { get }
    static var cyan: SystemColor { get }
    static var orange: SystemColor { get }
    static var purple: SystemColor { get }

    static var darkGray: SystemColor { get }
    static var lightGray: SystemColor { get }
    static var gray: SystemColor { get }
    static var brown: SystemColor { get }
}

#if os(macOS)
    extension NSColor: SystemColorPalette {
        public typealias SystemColor = NSColor
    }

    extension CGColor: SystemColorPalette {
        public typealias SystemColor = CGColor

        public static var red: SystemColor { NSColor.red.cgColor }
        public static var green: SystemColor { NSColor.green.cgColor }
        public static var blue: SystemColor { NSColor.blue.cgColor }
        public static var magenta: SystemColor { NSColor.magenta.cgColor }
        public static var yellow: SystemColor { NSColor.yellow.cgColor }
        public static var cyan: SystemColor { NSColor.cyan.cgColor }
        public static var orange: SystemColor { NSColor.orange.cgColor }
        public static var purple: SystemColor { NSColor.purple.cgColor }

        public static var darkGray: SystemColor { NSColor.darkGray.cgColor }
        public static var lightGray: SystemColor { NSColor.lightGray.cgColor }
        public static var gray: SystemColor { NSColor.gray.cgColor }
        public static var brown: SystemColor { NSColor.brown.cgColor }
    }

#elseif os(iOS) || os(tvOS)
    extension UIColor: SystemColorPalette {
        public typealias SystemColor = UIColor
    }

    extension CGColor: SystemColorPalette {
        public typealias SystemColor = CGColor

        public static var clear: SystemColor { UIColor.clear.cgColor }
        public static var white: SystemColor { UIColor.white.cgColor }
        public static var black: SystemColor { UIColor.black.cgColor }
        public static var red: SystemColor { UIColor.red.cgColor }
        public static var green: SystemColor { UIColor.green.cgColor }
        public static var blue: SystemColor { UIColor.blue.cgColor }
        public static var magenta: SystemColor { UIColor.magenta.cgColor }
        public static var yellow: SystemColor { UIColor.yellow.cgColor }
        public static var cyan: SystemColor { UIColor.cyan.cgColor }
        public static var orange: SystemColor { UIColor.orange.cgColor }
        public static var purple: SystemColor { UIColor.purple.cgColor }

        public static var darkGray: SystemColor { UIColor.darkGray.cgColor }
        public static var lightGray: SystemColor { UIColor.lightGray.cgColor }
        public static var gray: SystemColor { UIColor.gray.cgColor }
        public static var brown: SystemColor { UIColor.brown.cgColor }
    }
#endif
