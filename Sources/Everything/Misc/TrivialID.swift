//
//  TrivialID.swift
//  CacheTest
//
//  Created by Jonathan Wight on 5/10/24.
//

import Foundation
import os

public struct TrivialID: Sendable, Hashable {
    struct StaticState {
        var scopesByName: [String: Scope] = [:]
        var nextSerials: [Scope: Int] = [:]
    }

    static let staticState: OSAllocatedUnfairLock<StaticState> = .init(initialState: .init())

    struct Scope: Hashable {
        var name: String
        var token: Int

        init(name: String, token: Int = .random(in: 0...0xFFFFFF)) {
            self.name = name
            self.token = token
        }
    }

    static func scope(for name: String) -> Scope {
        Self.staticState.withLock { staticState in
            let scope = staticState.scopesByName[name, default: .init(name: name)]
            staticState.scopesByName[name] = scope
            return scope
        }
    }

    var scope: Scope
    var serial: Int

    private init(scope: Scope, serial: Int) {
        self.scope = scope
        self.serial = serial
    }

    public init(scope name: String = "") {
        self = Self.staticState.withLock { staticState in
            let scope = staticState.scopesByName[name, default: .init(name: name)]
            let serial = staticState.nextSerials[scope, default: 0] + 1
            staticState.scopesByName[name] = scope
            staticState.nextSerials[scope] = serial
            return .init(scope: scope, serial: serial)
        }
    }

    public static func dump() {
        staticState.withLock { staticState in
            debugPrint(staticState)
        }
    }
}

extension TrivialID: CustomStringConvertible {
    public var description: String {
        if scope.name.isEmpty {
            return "#\(serial)"
        }
        return "\(scope.name):#\(serial)"
    }
}

extension TrivialID: CustomDebugStringConvertible {
    public var debugDescription: String {
        "TrivialID(scope: \(scope), serial: \(serial))"
    }
}

/// Decoding a TrivialID is potentially a bad idea and can lead to ID conflicts if IDs have already been generated using the same scope.
extension TrivialID: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        let pattern = #/^(?<scopeName>.+)\.(?<scopeToken>.+):(?<serial>\d+)$/#
        guard let match = string.wholeMatch(of: pattern) else {
            fatalError()
        }
        guard let scopeToken = Int(match.output.scopeToken, radix: 16) else {
            fatalError()
        }
        guard let serial = Int(match.output.serial) else {
            fatalError()
        }
        let scope = Scope(name: String(match.output.scopeName), token: scopeToken)
        TrivialID.staticState.withLock { staticState in
            if staticState.scopesByName[scope.name] == nil {
                staticState.scopesByName[scope.name] = scope
            }
            staticState.nextSerials[scope] = max(staticState.nextSerials[scope, default: 0], serial)
        }
        self = .init(scope: scope, serial: serial)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode("\(scope.name).\(String(scope.token, radix: 16)):\(serial)")
    }
}

extension TrivialID.Scope: CustomDebugStringConvertible {
    var debugDescription: String {
        "\(name).\(String(token, radix: 16))"
    }
}
