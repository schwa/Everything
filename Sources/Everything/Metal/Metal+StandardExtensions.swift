import Metal

extension MTLPixelFormat: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalid:
            return "invalid"
        case .a8Unorm:
            return "a8Unorm"
        case .r8Unorm:
            return "r8Unorm"
        case .r8Snorm:
            return "r8Snorm"
        case .r8Uint:
            return "r8Uint"
        case .r8Sint:
            return "r8Sint"
        case .r16Unorm:
            return "r16Unorm"
        case .r16Snorm:
            return "r16Snorm"
        case .r16Uint:
            return "r16Uint"
        case .r16Sint:
            return "r16Sint"
        case .r16Float:
            return "r16Float"
        case .rg8Unorm:
            return "rg8Unorm"
        case .rg8Snorm:
            return "rg8Snorm"
        case .rg8Uint:
            return "rg8Uint"
        case .rg8Sint:
            return "rg8Sint"
        case .r32Uint:
            return "r32Uint"
        case .r32Sint:
            return "r32Sint"
        case .r32Float:
            return "r32Float"
        case .rg16Unorm:
            return "rg16Unorm"
        case .rg16Snorm:
            return "rg16Snorm"
        case .rg16Uint:
            return "rg16Uint"
        case .rg16Sint:
            return "rg16Sint"
        case .rg16Float:
            return "rg16Float"
        case .rgba8Unorm:
            return "rgba8Unorm"
        case .rgba8Unorm_srgb:
            return "rgba8Unorm_srgb"
        case .rgba8Snorm:
            return "rgba8Snorm"
        case .rgba8Uint:
            return "rgba8Uint"
        case .rgba8Sint:
            return "rgba8Sint"
        case .bgra8Unorm:
            return "bgra8Unorm"
        case .bgra8Unorm_srgb:
            return "bgra8Unorm_srgb"
        case .rgb10a2Unorm:
            return "rgb10a2Unorm"
        case .rgb10a2Uint:
            return "rgb10a2Uint"
        case .rg11b10Float:
            return "rg11b10Float"
        case .rgb9e5Float:
            return "rgb9e5Float"
        case .bgr10a2Unorm:
            return "bgr10a2Unorm"
        case .rg32Uint:
            return "rg32Uint"
        case .rg32Sint:
            return "rg32Sint"
        case .rg32Float:
            return "rg32Float"
        case .rgba16Unorm:
            return "rgba16Unorm"
        case .rgba16Snorm:
            return "rgba16Snorm"
        case .rgba16Uint:
            return "rgba16Uint"
        case .rgba16Sint:
            return "rgba16Sint"
        case .rgba16Float:
            return "rgba16Float"
        case .rgba32Uint:
            return "rgba32Uint"
        case .rgba32Sint:
            return "rgba32Sint"
        case .rgba32Float:
            return "rgba32Float"
        case .bc1_rgba:
            return "bc1_rgba"
        case .bc1_rgba_srgb:
            return "bc1_rgba_srgb"
        case .bc2_rgba:
            return "bc2_rgba"
        case .bc2_rgba_srgb:
            return "bc2_rgba_srgb"
        case .bc3_rgba:
            return "bc3_rgba"
        case .bc3_rgba_srgb:
            return "bc3_rgba_srgb"
        case .bc4_rUnorm:
            return "bc4_rUnorm"
        case .bc4_rSnorm:
            return "bc4_rSnorm"
        case .bc5_rgUnorm:
            return "bc5_rgUnorm"
        case .bc5_rgSnorm:
            return "bc5_rgSnorm"
        case .bc6H_rgbFloat:
            return "bc6H_rgbFloat"
        case .bc6H_rgbuFloat:
            return "bc6H_rgbuFloat"
        case .bc7_rgbaUnorm:
            return "bc7_rgbaUnorm"
        case .bc7_rgbaUnorm_srgb:
            return "bc7_rgbaUnorm_srgb"
        case .gbgr422:
            return "gbgr422"
        case .bgrg422:
            return "bgrg422"
        case .depth16Unorm:
            return "depth16Unorm"
        case .depth32Float:
            return "depth32Float"
        case .stencil8:
            return "stencil8"
        case .depth24Unorm_stencil8:
            return "depth24Unorm_stencil8"
        case .depth32Float_stencil8:
            return "depth32Float_stencil8"
        case .x32_stencil8:
            return "x32_stencil8"
        case .x24_stencil8:
            return "x24_stencil8"
        default:
            fatalError("Unknown pixel format \(rawValue)")
        }
    }
}

extension MTLVertexFormat: CustomStringConvertible {
    public var description: String {
        switch self {
        // swiftlint:disable switch_case_on_newline
        case .invalid: return "invalid"
        case .uchar2: return "uchar2"
        case .uchar3: return "uchar3"
        case .uchar4: return "uchar4"
        case .char2: return "char2"
        case .char3: return "char3"
        case .char4: return "char4"
        case .uchar2Normalized: return "uchar2Normalized"
        case .uchar3Normalized: return "uchar3Normalized"
        case .uchar4Normalized: return "uchar4Normalized"
        case .char2Normalized: return "char2Normalized"
        case .char3Normalized: return "char3Normalized"
        case .char4Normalized: return "char4Normalized"
        case .ushort2: return "ushort2"
        case .ushort3: return "ushort3"
        case .ushort4: return "ushort4"
        case .short2: return "short2"
        case .short3: return "short3"
        case .short4: return "short4"
        case .ushort2Normalized: return "ushort2Normalized"
        case .ushort3Normalized: return "ushort3Normalized"
        case .ushort4Normalized: return "ushort4Normalized"
        case .short2Normalized: return "short2Normalized"
        case .short3Normalized: return "short3Normalized"
        case .short4Normalized: return "short4Normalized"
        case .half2: return "half2"
        case .half3: return "half3"
        case .half4: return "half4"
        case .float: return "float"
        case .float2: return "float2"
        case .float3: return "float3"
        case .float4: return "float4"
        case .int: return "int"
        case .int2: return "int2"
        case .int3: return "int3"
        case .int4: return "int4"
        case .uint: return "uint"
        case .uint2: return "uint2"
        case .uint3: return "uint3"
        case .uint4: return "uint4"
        case .int1010102Normalized: return "int1010102Normalized"
        case .uint1010102Normalized: return "uint1010102Normalized"
        case .uchar4Normalized_bgra: return "uchar4Normalized_bgra"
        case .uchar: return "uchar"
        case .char: return "char"
        case .ucharNormalized: return "ucharNormalized"
        case .charNormalized: return "charNormalized"
        case .ushort: return "ushort"
        case .short: return "short"
        case .ushortNormalized: return "ushortNormalized"
        case .shortNormalized: return "shortNormalized"
        case .half: return "half"
        default:
            fatal(error: GeneralError.illegalValue)
        }
    }
}

extension MTLArgumentBuffersTier: CustomStringConvertible {
    public var description: String {
        switch self {
        case .tier1:
            return "tier1"
        case .tier2:
            return "tier2"
        @unknown default:
            fatal(error: GeneralError.illegalValue)
        }
    }
}

extension MTLReadWriteTextureTier: CustomStringConvertible {
    public var description: String {
        switch self {
        case .tierNone:
            return "none"
        case .tier1:
            return "tier1"
        case .tier2:
            return "tier2"
        @unknown default:
            fatal(error: GeneralError.illegalValue)
        }
    }
}
