import Foundation

public struct AnyDecodable: Decodable {
    public var value: Any

    private struct CodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int?
        init?(intValue: Int) {
            stringValue = "\(intValue)"
            self.intValue = intValue
        }

        init?(stringValue: String) { self.stringValue = stringValue }
    }

    public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            var result = [String: Any]()
            try container.allKeys.forEach { key throws in
                result[key.stringValue] = try container.decode(Self.self, forKey: key).value
            }
            value = result
        } else if var container = try? decoder.unkeyedContainer() {
            var result = [Any]()
            while !container.isAtEnd {
                result.append(try container.decode(Self.self).value)
            }
            value = result
        } else if let container = try? decoder.singleValueContainer() {
            if let intVal = try? container.decode(Int.self) {
                value = intVal
            } else if let doubleVal = try? container.decode(Double.self) {
                value = doubleVal
            } else if let boolVal = try? container.decode(Bool.self) {
                value = boolVal
            } else if let stringVal = try? container.decode(String.self) {
                value = stringVal
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "the container contains nothing serialisable")
            }
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Could not serialise"))
        }
    }
}

// let json = """
// {
// "id": 12345,
// "name": "Giuseppe",
// "last_name": "Lanza",
// "age": 31,
// "happy": true,
// "rate": 1.5,
// "classes": ["maths", "phisics"],
// "dogs": [
// {
// "name": "Gala",
// "age": 1
// }, {
// "name": "Aria",
// "age": 3
// }
// ]
// }
// """

// func test() {
// let jsonData = json.data(using: .utf8)!
// let stud = try! JSONDecoder().decode(AnyDecodable.self, from: jsonData).value as! [String: Any]
// print(stud)
// }
