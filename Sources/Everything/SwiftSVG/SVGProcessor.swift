// swiftlint:disable identifier_name

import Foundation

#if os(macOS)
//
    public class SVGProcessor {
        public class State {
            var document: SVGDocument?
            var elementsByID: [String: SVGElement] = [:]
            var events: [Event] = []
        }

        public struct Event {
            enum Severity {
                case debug
                case info
                case warning
                case error
            }

            let severity: Severity
            let message: String
        }

        public enum Error: Swift.Error {
            case corruptXML
            case expectedSVGElementNotFound
        }

        public init() {
        }

        public func processXMLDocument(_ xmlDocument: XMLDocument) throws -> SVGDocument? {
            let rootElement = xmlDocument.rootElement()!
            let state = State()
            let document = try processSVGElement(rootElement, state: state) as? SVGDocument
            if state.events.isEmpty == false {
                for event in state.events {
                    warning("\(event)")
                }
            }
            return document
        }

        public func processSVGDocument(_ xmlElement: XMLElement, state: State) throws -> SVGDocument {
            let document = SVGDocument()
            state.document = document

            // Version.
            if let version = xmlElement["version"]?.stringValue {
                switch version {
                case "1.1":
                    document.profile = .full
                    document.version = SVGDocument.Version(majorVersion: 1, minorVersion: 1)
                default:
                    break
                }
                xmlElement["version"] = nil
            }

            // Viewbox.
            if let viewbox = xmlElement["viewBox"]?.stringValue {
                let VALUE_LIST = RangeOf(min: 4, max: 4, subelement: (DoubleValue() + OPT_COMMA).makeStripped().makeFlattened())

                // TODO: ! can and will crash with bad data.
                forceTry {
                    let values: [CGFloat] = (try VALUE_LIST.parse(viewbox) as? [Any])!.map {
                        $0 as! CGFloat
                    }

                    let (x, y, width, height) = (values[0], values[1], values[2], values[3])
                    document.viewBox = CGRect(x: x, y: y, width: width, height: height)

                    xmlElement["viewBox"] = nil
                }
            }

            // Children
            if let nodes = xmlElement.children as? [XMLElement] {
                for node in nodes {
                    if let svgElement = try processSVGElement(node, state: state) {
                        svgElement.parent = document
                        document.children.append(svgElement)
                    }
                }
                xmlElement.setChildren(nil)
            }

            return document
        }

        // swiftlint:disable:next cyclomatic_complexity
        public func processSVGElement(_ xmlElement: XMLElement, state: State) throws -> SVGElementType? {
            var svgElement: SVGElement?

            guard let name = xmlElement.name else {
                throw Error.corruptXML
            }

            switch name {
            case "svg":
                svgElement = try processSVGDocument(xmlElement, state: state)
            case "g":
                svgElement = try processSVGGroup(xmlElement, state: state)
            case "path":
                svgElement = try processSVGPath(xmlElement, state: state)
            case "title":
                state.document!.title = xmlElement.stringValue as String?
            case "desc":
                state.document!.documentDescription = xmlElement.stringValue as String?
            default:
                state.events.append(Event(severity: .warning, message: "Unhandled element \(String(describing: xmlElement.name))"))
                return nil
            }

            if let svgElement {
                svgElement.style = try processStyle(xmlElement, state: state)
                svgElement.transform = try processTransform(xmlElement, state: state)

                if let id = xmlElement["id"]?.stringValue {
                    svgElement.id = id
                    if state.elementsByID[id] != nil {
                        state.events.append(Event(severity: .warning, message: "Duplicate elements with id \"\(id)\"."))
                    }
                    state.elementsByID[id] = svgElement

                    xmlElement["id"] = nil
                }

                if (xmlElement.attributes?.count)! > 0 {
                    state.events.append(Event(severity: .warning, message: "Unhandled attributes: \(xmlElement))"))
                    svgElement.xmlElement = xmlElement
                }
            }

            return svgElement
        }

        public func processSVGGroup(_ xmlElement: XMLElement, state: State) throws -> SVGGroup {
            let nodes = xmlElement.children! as! [XMLElement]

            let children = try nodes.compactMap {
                try processSVGElement($0, state: state)
            }
            let group = SVGGroup(children: children)
            xmlElement.setChildren(nil)
            return group
        }

        public func processSVGPath(_ xmlElement: XMLElement, state: State) throws -> SVGPath? {
            guard let string = xmlElement["d"]?.stringValue else {
                throw Error.expectedSVGElementNotFound
            }

            let path = CGPathFromSVGPath(string)
            xmlElement["d"] = nil
            return SVGPath(path: path)
        }

        public func processStyle(_ xmlElement: XMLElement, state: State) throws -> Style? {
            var styleElements: [StyleElement] = []

            // http: //www.w3.org/TR/SVG/styling.html

            // Fill
            if let value = xmlElement["fill"]?.stringValue {
                if let color = try stringToColor(value) {
                    let element = StyleElement.fillColor(color)
                    styleElements.append(element)
                }

                xmlElement["fill"] = nil
            }

            // Stroke
            if let value = xmlElement["stroke"]?.stringValue {
                if let color = try stringToColor(value) {
                    let element = StyleElement.strokeColor(color)
                    styleElements.append(element)
                }

                xmlElement["stroke"] = nil
            }

            // Stroke-Width
            if let value = xmlElement["stroke-width"]?.stringValue {
                if let double = NumberFormatter().number(from: value)?.doubleValue {
                    let element = StyleElement.lineWidth(double)
                    styleElements.append(element)
                }

                xmlElement["stroke-width"] = nil
            }

            //
            if styleElements.isEmpty == false {
                return Style(elements: styleElements)
            }
            else {
                return nil
            }
        }

        public func processTransform(_ xmlElement: XMLElement, state: State) throws -> Transform2D? {
            guard let value = xmlElement["transform"]?.stringValue else {
                return nil
            }
            let transform = try svgTransformAttributeStringToTransform(string: value)
            xmlElement["transform"] = nil
            return transform
        }

        func stringToColor(_ string: String) throws -> SVGColor? {
            if string == "none" {
                return nil
            }

            return try ColorParser().color(for: string)
        }
    }

    extension SVGProcessor.Event: CustomStringConvertible {
        public var description: String {
            switch severity {
            case .debug:
                return "DEBUG: \(message)"
            case .info:
                return "INFO: \(message)"
            case .warning:
                return "WARNING: \(message)"
            case .error:
                return "ERROR: \(message)"
            }
        }
    }

#endif
