import Foundation

public struct CSVFormatter {
    public struct Options {
        public var quote: String = "\""
        public var delimiter: String = ","
        public var recordDelimiter: String = "\n"

        public enum QuoteLevel {
            case none
            case all
            case minimal
            case nonnumeric
        }

        public var quoteLevel: QuoteLevel = .minimal
        public var doubleQuote = true
        public var escape: String?
        public var skipInitialSpace = false

        public init() {
        }
    }

    public var options = Options()

    public init(options: Options = Options()) {
        self.options = options
    }

    public func formatField(_ field: String) -> String {
        let specials = options.quote + options.delimiter + options.recordDelimiter
        var field = field
        let quote: Bool
        switch options.quoteLevel {
        case .none:
            quote = false
        case .all, .nonnumeric:
            quote = true
        case .minimal:
            quote = field.contains {
                specials.contains($0)
            }
        }

        if quote && options.doubleQuote {
            field = field.replacingOccurrences(of: options.quote, with: options.quote + options.quote)
        }
        else if let escape = options.escape, options.quoteLevel == .none {
            field = field.replacingOccurrences(of: escape, with: escape + escape)
            field = field.replacingOccurrences(of: options.quote, with: escape + options.quote)
            field = field.replacingOccurrences(of: options.delimiter, with: escape + options.delimiter)
            field = field.replacingOccurrences(of: options.recordDelimiter, with: escape + options.recordDelimiter)
        }
        return quote ? options.quote + field + options.quote : field
    }

    public func formatFields(_ fields: [String]) -> String {
        fields.map {
            formatField($0)
        }
        .joined(separator: options.delimiter)
        + options.recordDelimiter
    }
}
