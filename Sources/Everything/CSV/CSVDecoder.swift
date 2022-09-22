import Foundation

struct CSVDecoder {
}

public struct CSVReader {
    let data: Data
    public enum LineEnding {
        case CR
        case LF
        case CRLF
    }

    let lineEndings: LineEnding

    public init(data: Data, lineEndings: LineEnding = .CRLF) {
        self.data = data
        self.lineEndings = lineEndings
    }

    public init(url: URL, lineEndings: LineEnding = .CRLF) throws {
        let data = try Data(contentsOf: url, options: .mappedIfSafe)
        self = CSVReader(data: data, lineEndings: lineEndings)
        // TODO: Dont ignore BOM on other encodings
    }

    public func makeIterator() -> AnyIterator<[String]> {
        let lineEndings: [UInt8]
        switch self.lineEndings {
        case .LF:
            lineEndings = [0x0A]
        case .CR:
            lineEndings = [0x0D]
        case .CRLF:
            lineEndings = [0x0D, 0x0A]
        }

        var fileScanner = CollectionScanner(elements: data)

        // MS Excel inserts a BOM even for UTF-8 files.
        _ = fileScanner.scan(value: [0xEF, 0xBB, 0xBF])

        let lineIterator = fileScanner.iterator(forComponentsSeparatedBy: lineEndings)
        return AnyIterator<[String]> {
            guard let line = lineIterator.next() else {
                return nil
            }
            let lineString = String(decoding: line, as: UTF8.self)
            var lineScanner = CollectionScanner(elements: lineString)
            // TODO: Handle quotes and escapes and all that jazz. UNIT TESTS
            return lineScanner.scanCSVFields()
        }
    }
}

public struct CSVDictReader {
    let reader: CSVReader

    public init(data: Data, lineEndings: CSVReader.LineEnding = .CRLF) {
        reader = CSVReader(data: data, lineEndings: lineEndings)
    }

    public init(url: URL, lineEndings: CSVReader.LineEnding = .CRLF) throws {
        reader = try CSVReader(url: url, lineEndings: lineEndings)
    }

    public func makeIterator() -> AnyIterator<[String: String]> {
        let recordIterator = reader.makeIterator()
        guard let keys = recordIterator.next() else {
            return NilIterator().eraseToAnyIterator()
        }
        return AnyIterator {
            guard let values = recordIterator.next() else {
                return nil
            }
            return Dictionary(uniqueKeysWithValues: zip(keys, values))
        }
    }
}

public struct SharedKeys<Key> {
    let keys: [Key]
}

public struct SharedKeysDictionary<Key, Value> {
    let keys: SharedKeys<Key>
    let values: [Value]
}

public extension CollectionScanner {
    mutating func scanCSVFields() -> [String] where C == String {
        var fields: [String] = []
        while !atEnd {
            assertChange(value: current) {
                if scan(value: "\"") {
                    var field = ""
                    while !atEnd {
                        if let chunk = scanUpTo(value: "\"").map(String.init) {
                            field.append(chunk)
                        }
                        _ = scan(value: "\"")
                        if peek() == "\"" {
                            _ = scan(value: "\"")
                            field.append("\"")
                        }
                        else {
                            fields.append(field)
                            break
                        }
                    }
                }
                else if let field = scanUpTo(value: ",").map(String.init) {
                    fields.append(field)
                }
                if scan(value: ",") {
                    if atEnd {
                        fields.append("")
                    }
                }
            }
        }
        return fields
    }
}
