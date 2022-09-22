#if os(macOS)
    import CoreGraphics
    import Foundation

    public protocol SVGElementType: AnyObject {
        var parent: SVGContainerType? { get set }
        var style: Style? { get set }
        var transform: Transform2D? { get set }
        var id: String? { get }
    }

    public protocol SVGContainerType: SVGElementType {
        var children: [SVGElementType] { get }
    }

    // MARK: -

    public class SVGElement: NSObject, SVGElementType {
        public weak var parent: SVGContainerType?
        public var style: Style?
        public var transform: Transform2D?
        public internal(set) var id: String?
        public internal(set) var xmlElement: XMLElement?
    }

    // MARK: -

    public class SVGContainer: SVGElement, SVGContainerType {
        public var children: [SVGElementType] = [] {
            didSet {
                children.forEach { $0.parent = self }
            }
        }

        public convenience init(children: [SVGElementType]) {
            self.init()
            self.children = children
            self.children.forEach { $0.parent = self }
        }
    }

    // MARK: -

//    public extension SVGContainer {
//        func replace(oldElement: SVGElementType, with newElement: SVGElementType) throws {
//            guard let index = children.index(of: oldElement) else {
//                throw NSError(domain: "TODO", code: -1, userInfo: nil)
//            }
//            oldElement.parent = nil
//            children[index] = newElement
//            newElement.parent = self
//        }
//    }

    // MARK: -

    public class SVGDocument: SVGContainer {
        public enum Profile {
            case full
            case tiny
            case basic
        }

        public struct Version {
            let majorVersion: Int
            let minorVersion: Int
        }

        public var profile: Profile?
        public var version: Version?
        public var viewBox: CGRect!
        public var title: String?
        public var documentDescription: String?
    }

    // MARK: -

    public class SVGGroup: SVGContainer {
    }

    // MARK: -

    // public protocol SVGGeometryNode: Node {
//    var drawable: Drawable { get }
    // }

    // MARK: -

    public class SVGPath: SVGElement, CGPathable {
        public internal(set) var cgpath: CGPath

        public init(path: CGPath) {
            cgpath = path
        }
    }
#endif // os(macOS)
