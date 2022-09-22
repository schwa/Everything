import CoreGraphics
import Metal
import simd

#if os(macOS)
    public func allHeadlessDevices() -> [MTLDevice] {
        MTLCopyAllDevices().filter { $0.isHeadless == true }
    }

    public func allLowPowerDevices() -> [MTLDevice] {
        MTLCopyAllDevices().filter { $0.isLowPower == true }
    }
#endif

public extension MTLAttributeDescriptor {
    convenience init(format: MTLAttributeFormat, offset: Int = 0, bufferIndex: Int) {
        self.init()
        self.format = format
        self.offset = offset
        self.bufferIndex = bufferIndex
    }
}

public extension MTLTexture {
    var size: MTLSize {
        MTLSize(width, height, depth)
    }

    var region: MTLRegion {
        MTLRegion(origin: .zero, size: size)
    }
}

public extension MTLPixelFormat {
    var bits: Int? {
        switch self {
        /* Normal 8 bit formats */
        case .a8Unorm, .r8Unorm, .r8Unorm_srgb, .r8Snorm, .r8Uint, .r8Sint:
            return 8
        /* Normal 16 bit formats */
        case .r16Unorm, .r16Snorm, .r16Uint, .r16Sint, .r16Float, .rg8Unorm, .rg8Unorm_srgb, .rg8Snorm, .rg8Uint, .rg8Sint:
            return 16
        /* Packed 16 bit formats */
        case .b5g6r5Unorm, .a1bgr5Unorm, .abgr4Unorm, .bgr5A1Unorm:
            return 16
        /* Normal 32 bit formats */
        case .r32Uint, .r32Sint, .r32Float, .rg16Unorm, .rg16Snorm, .rg16Uint, .rg16Sint, .rg16Float, .rgba8Unorm, .rgba8Unorm_srgb, .rgba8Snorm, .rgba8Uint, .rgba8Sint, .bgra8Unorm, .bgra8Unorm_srgb:
            return 32
        /* Packed 32 bit formats */
        case .rgb10a2Unorm, .rgb10a2Uint, .rg11b10Float, .rgb9e5Float, .bgr10a2Unorm, .bgr10_xr, .bgr10_xr_srgb:
            return 32
        /* Normal 64 bit formats */
        case .rg32Uint, .rg32Sint, .rg32Float, .rgba16Unorm, .rgba16Snorm, .rgba16Uint, .rgba16Sint, .rgba16Float, .bgra10_xr, .bgra10_xr_srgb:
            return 64
        /* Normal 128 bit formats */
        case .rgba32Uint, .rgba32Sint, .rgba32Float:
            return 128
        /* Depth */
        case .depth16Unorm:
            return 16
        case .depth32Float:
            return 32
        /* Stencil */
        case .stencil8:
            return 8
        /* Depth Stencil */
        case .depth24Unorm_stencil8:
            return 32
        case .depth32Float_stencil8:
            return 40
        case .x32_stencil8:
            return nil
        case .x24_stencil8:
            return nil
        default:
            return nil
        }
    }

    var size: Int? {
        bits.map { $0 / 8 }
    }
}

public extension MTLOrigin {
    static var zero: MTLOrigin {
        MTLOrigin(x: 0, y: 0, z: 0)
    }
}

public extension MTLSize {
    init(_ width: Int, _ height: Int, _ depth: Int) {
        self = MTLSize(width: width, height: height, depth: depth)
    }
}

public extension MTLDevice {
    @available(*, deprecated, message: "TODO")
    func make2DTexture(pixelFormat: MTLPixelFormat = .rgba8Unorm, size: SIMD2<Int>, mipmapped: Bool = false, usage: MTLTextureUsage? = nil) -> MTLTexture {
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat, width: size.x, height: size.y, mipmapped: mipmapped)
        if let usage {
            textureDescriptor.usage = usage
        }
        return makeTexture(descriptor: textureDescriptor)!
    }
}

public extension MTLTexture {
    func clear(color: SIMD4<UInt8> = [0, 0, 0, 0]) {
        assert(depth == 1)
        let buffer = Array(repeatElement(color, count: width * height * depth))
        assert(MemoryLayout<SIMD4<UInt8>>.stride == pixelFormat.size)
        buffer.withUnsafeBytes { pointer in
            replace(region: region, mipmapLevel: 0, withBytes: pointer.baseAddress!, bytesPerRow: width * MemoryLayout<SIMD4<UInt8>>.stride)
        }
    }
}

public extension MTLBuffer {
    func data() -> Data {
        Data(bytes: contents(), count: length)
    }
}

public extension MTLPrimitiveType {
    var vertexCount: Int? {
        switch self {
        case .triangle:
            return 3
        default:
            fatal(error: GeneralError.illegalValue)
        }
    }
}

public extension CGSize {
    init(_ size: SIMD2<Double>) {
        self = CGSize(width: CGFloat(size.x), height: CGFloat(size.y))
    }
}

public extension MTLIndexType {
    var indexSize: Int {
        switch self {
        case .uint16:
            return MemoryLayout<UInt16>.size
        case .uint32:
            return MemoryLayout<UInt32>.size
        default:
            fatal(error: GeneralError.illegalValue)
        }
    }
}
