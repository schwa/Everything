import Foundation

public class Box<Element> {
    public let value: Element
    public init(_ value: Element) {
        self.value = value
    }
}

public extension Box {
    // Stolen from https://github.com/robrix/Box/blob/master/Box/Box.swift
    func map<U>(_ transform: (Element) -> U) -> Box<U> {
        Box<U>(transform(value))
    }
}

extension Box: CustomStringConvertible {
    public var description: String {
        String(describing: value)
    }
}
