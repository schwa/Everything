public enum Endianness {
    case big
    case little
    public static var Native: Endianness = {
        #if arch(x86_64) || arch(arm) || arch(arm64) || arch(i386)
        return .little
        #else
        // return UInt16(littleEndian: 1234) == 1234 ? .Little : .Big
        fatalError("Unknown Endianness")
        #endif
    }()

    public static var Network: Endianness = .big
}

// MARK: -

public protocol EndianConvertable {
    func fromEndianness(_ endianness: Endianness) -> Self
    func toEndianness(_ endianness: Endianness) -> Self
}

// MARK: -

extension UInt: EndianConvertable {
    public func fromEndianness(_ endianness: Endianness) -> UInt {
        switch endianness {
        case .big:
            return UInt(bigEndian: self)

        case .little:
            return UInt(littleEndian: self)
        }
    }

    public func toEndianness(_ endianness: Endianness) -> UInt {
        switch endianness {
        case .big:
            return bigEndian

        case .little:
            return littleEndian
        }
    }
}

extension UInt8: EndianConvertable {
    public func fromEndianness(_: Endianness) -> UInt8 {
        self
    }

    public func toEndianness(_: Endianness) -> UInt8 {
        self
    }
}

extension UInt16: EndianConvertable {
    public func fromEndianness(_ endianness: Endianness) -> UInt16 {
        switch endianness {
        case .big:
            return UInt16(bigEndian: self)

        case .little:
            return UInt16(littleEndian: self)
        }
    }

    public func toEndianness(_ endianness: Endianness) -> UInt16 {
        switch endianness {
        case .big:
            return bigEndian

        case .little:
            return littleEndian
        }
    }
}

extension UInt32: EndianConvertable {
    public func fromEndianness(_ endianness: Endianness) -> UInt32 {
        switch endianness {
        case .big:
            return UInt32(bigEndian: self)

        case .little:
            return UInt32(littleEndian: self)
        }
    }

    public func toEndianness(_ endianness: Endianness) -> UInt32 {
        switch endianness {
        case .big:
            return bigEndian

        case .little:
            return littleEndian
        }
    }
}

extension UInt64: EndianConvertable {
    public func fromEndianness(_ endianness: Endianness) -> UInt64 {
        switch endianness {
        case .big:
            return UInt64(bigEndian: self)

        case .little:
            return UInt64(littleEndian: self)
        }
    }

    public func toEndianness(_ endianness: Endianness) -> UInt64 {
        switch endianness {
        case .big:
            return bigEndian

        case .little:
            return littleEndian
        }
    }
}

// MARK: -

extension Int: EndianConvertable {
    public func fromEndianness(_ endianness: Endianness) -> Int {
        switch endianness {
        case .big:
            return Int(bigEndian: self)

        case .little:
            return Int(littleEndian: self)
        }
    }

    public func toEndianness(_ endianness: Endianness) -> Int {
        switch endianness {
        case .big:
            return bigEndian

        case .little:
            return littleEndian
        }
    }
}

extension Int8: EndianConvertable {
    public func fromEndianness(_: Endianness) -> Int8 {
        self
    }

    public func toEndianness(_: Endianness) -> Int8 {
        self
    }
}

extension Int16: EndianConvertable {
    public func fromEndianness(_ endianness: Endianness) -> Int16 {
        switch endianness {
        case .big:
            return Int16(bigEndian: self)

        case .little:
            return Int16(littleEndian: self)
        }
    }

    public func toEndianness(_ endianness: Endianness) -> Int16 {
        switch endianness {
        case .big:
            return bigEndian

        case .little:
            return littleEndian
        }
    }
}

extension Int32: EndianConvertable {
    public func fromEndianness(_ endianness: Endianness) -> Int32 {
        switch endianness {
        case .big:
            return Int32(bigEndian: self)

        case .little:
            return Int32(littleEndian: self)
        }
    }

    public func toEndianness(_ endianness: Endianness) -> Int32 {
        switch endianness {
        case .big:
            return bigEndian

        case .little:
            return littleEndian
        }
    }
}

extension Int64: EndianConvertable {
    public func fromEndianness(_ endianness: Endianness) -> Int64 {
        switch endianness {
        case .big:
            return Int64(bigEndian: self)

        case .little:
            return Int64(littleEndian: self)
        }
    }

    public func toEndianness(_ endianness: Endianness) -> Int64 {
        switch endianness {
        case .big:
            return bigEndian

        case .little:
            return littleEndian
        }
    }
}
