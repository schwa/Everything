// swiftlint:disable line_length

import Foundation

public protocol ColorProtocol {
    init(red: UInt8, green: UInt8, blue: UInt8)
    init(red: Double, green: Double, blue: Double)
}

public struct ColorParsingOptions: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let allowThreeDigitHex = ColorParsingOptions(rawValue: 0b00001)
    public static let allowSixDititHex = ColorParsingOptions(rawValue: 0b00010)
    public static let allowIntegerFunctional = ColorParsingOptions(rawValue: 0b00100)
    public static let allowFloatFunctional = ColorParsingOptions(rawValue: 0b01000)
    public static let allowKeyword = ColorParsingOptions(rawValue: 0b10000)

    public static let `default`: ColorParsingOptions = [allowThreeDigitHex, allowSixDititHex, allowIntegerFunctional, allowFloatFunctional, allowKeyword]
}

/*
Three digit hex — #rgb
Each hexadecimal digit, in the range 0 to F, represents one sRGB color component in the order red, green and blue. The digits A to F may be in either uppercase or lowercase. The value of the color component is obtained by replicating digits, so 0 become 00, 1 becomes 11, F becomes FF. This compact syntactical form can represent only 4096 colors. Examples: #000 (i.e. black) #fff (i.e. white) #6CF (i.e. #66CCFF, rgb(102, 204, 255)).
Six digit hex — #rrggbb
Each pair of hexadecimal digits, in the range 0 to F, represents one sRGB color component in the order red, green and blue. The digits A to F may be in either uppercase or lowercase.This syntactical form, originally introduced by HTML, can represent 16777216 colors. Examples: #9400D3 (i.e. a dark violet), #FFD700 (i.e. a golden color).
Integer functional — rgb(rrr, ggg, bbb)
Each integer represents one sRGB color component in the order red, green and blue, separated by a comma and optionally by white space. Each integer is in the range 0 to 255. This syntactical form can represent 16777216 colors. Examples: rgb(233, 150, 122) (i.e. a salmon pink), rgb(255, 165, 0) (i.e. an orange).
Float functional — rgb(R%, G%, B%)
Each percentage value represents one sRGB color component in the order red, green and blue, separated by a comma and optionally by white space. For colors inside the sRGB gamut, the range of each component is 0.0% to 100.0% and an arbitrary number of decimal places may be supplied. Scientific notation is not supported. This syntactical form can represent an arbitrary range of colors, completely covering the sRGB gamut. Color values where one or more components are below 0.0% or above 100.0% represent colors outside the sRGB gamut. Examples: rgb(12.375%, 34.286%, 28.97%).
Color keyword
Originally implemented in HTML browsers and eventually standardized in SVG 1.1, the full list of color keywords and their corresponding sRGB values are given in the SVG 1.1 specification. SVG Tiny 1.2 required only a subset of these, sixteen color keywords. SVG Color requires the full set to be supported.
*/

public struct ColorParser {
    public enum Error: Swift.Error {
        case generic
    }

    public init() {
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    public func color<C>(for string: String) throws -> C where C: ColorProtocol {
        let scanner = Scanner(string: string)

        if scanner.scanString("#") != nil {
            scanner.charactersToBeSkipped = nil
            guard let string = scanner.scanCharacters(from: .hexdigits) else {
                throw Error.generic
            }
            let count = string.utf8.count
            switch count {
            case 3:
                let values = string.map {
                    UInt8(hexToInt(String($0) + String($0)))
                }
                assert(values.count == 3)
                return C(red: values[0], green: values[1], blue: values[2])
            case 6:
                let values = [0 ..< 2, 2 ..< 4, 4 ..< 6].map {
                    let a = string.index(string.startIndex, offsetBy: $0.lowerBound, limitedBy: string.endIndex)!
                    let b = string.index(string.startIndex, offsetBy: $0.upperBound, limitedBy: string.endIndex)!

                    return String(string[a ..< b])
                }
                .map {
                    UInt8(hexToInt($0))
                }
                assert(values.count == 3)
                return C(red: values[0], green: values[1], blue: values[2])
            default:
                throw Error.generic
            }
        }

        // TODO: Precompile expression. Add whitespace.
        if let match = try scanner.scan(regularExpression: "rgb\\(([0-9]{1,3}),([0-9]{1,3}),([0-9]{1,3})\\)") {
            let values: [UInt8] = try (1 ... 3).map {
                guard let value = Int((scanner.string as NSString).substring(with: match.range(at: $0))) else {
                    throw Error.generic
                }
                guard (0 ... 255).contains(value) else {
                    throw Error.generic
                }
                return UInt8(value)
            }
            return C(red: values[0], green: values[1], blue: values[2])
        }

        // TODO: Precompile expression. Add whitespace. Use full floating point regex representation
        if let match = try scanner.scan(regularExpression: "rgb\\(([0-9]{1,3})%,([0-9]{1,3})%,([0-9]{1,3})%\\)") {
            let values: [Double] = try (1 ... 3).map {
                guard let value = Double((scanner.string as NSString).substring(with: match.range(at: $0))) else {
                    throw Error.generic
                }
                guard (0 ... 100).contains(value) else {
                    throw Error.generic
                }
                return value / 100
            }
            return C(red: values[0], green: values[1], blue: values[2])
        }

        if let rawColor = rawColors[string] {
            return C(red: rawColor.0, green: rawColor.1, blue: rawColor.2)
        }

        throw Error.generic
    }
}

func hexToInt(_ string: String) -> Int {
    string.utf8.reduce(0) { accumulator, c -> Int in
        let c = Int(c)
        return accumulator << 4 | c & 0xF + c >> 6 | (c & 0x40) >> 3
    }
}

//
//  Colors.swift
//  GraphicsDemos
//
//  Created by Jonathan Wight on 9/16/17.
//  Copyright © 2017 schwa.io. All rights reserved.
//

let rawColors: [String: (UInt8, UInt8, UInt8)] = [
    "aliceblue": (240, 248, 255),
    "antiquewhite": (250, 235, 215),
    "aqua": (0, 255, 255),
    "aquamarine": (127, 255, 212),
    "azure": (240, 255, 255),
    "beige": (245, 245, 220),
    "bisque": (255, 228, 196),
    "black": (0, 0, 0),
    "blanchedalmond": (255, 235, 205),
    "blue": (0, 0, 255),
    "blueviolet": (138, 43, 226),
    "brown": (165, 42, 42),
    "burlywood": (222, 184, 135),
    "cadetblue": (95, 158, 160),
    "chartreuse": (127, 255, 0),
    "chocolate": (210, 105, 30),
    "coral": (255, 127, 80),
    "cornflowerblue": (100, 149, 237),
    "cornsilk": (255, 248, 220),
    "crimson": (220, 20, 60),
    "cyan": (0, 255, 255),
    "darkblue": (0, 0, 139),
    "darkcyan": (0, 139, 139),
    "darkgoldenrod": (184, 134, 11),
    "darkgray": (169, 169, 169),
    "darkgreen": (0, 100, 0),
    "darkgrey": (169, 169, 169),
    "darkkhaki": (189, 183, 107),
    "darkmagenta": (139, 0, 139),
    "darkolivegreen": (85, 107, 47),
    "darkorange": (255, 140, 0),
    "darkorchid": (153, 50, 204),
    "darkred": (139, 0, 0),
    "darksalmon": (233, 150, 122),
    "darkseagreen": (143, 188, 143),
    "darkslateblue": (72, 61, 139),
    "darkslategray": (47, 79, 79),
    "darkslategrey": (47, 79, 79),
    "darkturquoise": (0, 206, 209),
    "darkviolet": (148, 0, 211),
    "deeppink": (255, 20, 147),
    "deepskyblue": (0, 191, 255),
    "dimgray": (105, 105, 105),
    "dimgrey": (105, 105, 105),
    "dodgerblue": (30, 144, 255),
    "firebrick": (178, 34, 34),
    "floralwhite": (255, 250, 240),
    "forestgreen": (34, 139, 34),
    "fuchsia": (255, 0, 255),
    "gainsboro": (220, 220, 220),
    "ghostwhite": (248, 248, 255),
    "gold": (255, 215, 0),
    "goldenrod": (218, 165, 32),
    "gray": (128, 128, 128),
    "grey": (128, 128, 128),
    "green": (0, 128, 0),
    "greenyellow": (173, 255, 47),
    "honeydew": (240, 255, 240),
    "hotpink": (255, 105, 180),
    "indianred": (205, 92, 92),
    "indigo": (75, 0, 130),
    "ivory": (255, 255, 240),
    "khaki": (240, 230, 140),
    "lavender": (230, 230, 250),
    "lavenderblush": (255, 240, 245),
    "lawngreen": (124, 252, 0),
    "lemonchiffon": (255, 250, 205),
    "lightblue": (173, 216, 230),
    "lightcoral": (240, 128, 128),
    "lightcyan": (224, 255, 255),
    "lightgoldenrodyellow": (250, 250, 210),
    "lightgray": (211, 211, 211),
    "lightgreen": (144, 238, 144),
    "lightgrey": (211, 211, 211),
    "lightpink": (255, 182, 193),
    "lightsalmon": (255, 160, 122),
    "lightseagreen": (32, 178, 170),
    "lightskyblue": (135, 206, 250),
    "lightslategray": (119, 136, 153),
    "lightslategrey": (119, 136, 153),
    "lightsteelblue": (176, 196, 222),
    "lightyellow": (255, 255, 224),
    "lime": (0, 255, 0),
    "limegreen": (50, 205, 50),
    "linen": (250, 240, 230),
    "magenta": (255, 0, 255),
    "maroon": (128, 0, 0),
    "mediumaquamarine": (102, 205, 170),
    "mediumblue": (0, 0, 205),
    "mediumorchid": (186, 85, 211),
    "mediumpurple": (147, 112, 219),
    "mediumseagreen": (60, 179, 113),
    "mediumslateblue": (123, 104, 238),
    "mediumspringgreen": (0, 250, 154),
    "mediumturquoise": (72, 209, 204),
    "mediumvioletred": (199, 21, 133),
    "midnightblue": (25, 25, 112),
    "mintcream": (245, 255, 250),
    "mistyrose": (255, 228, 225),
    "moccasin": (255, 228, 181),
    "navajowhite": (255, 222, 173),
    "navy": (0, 0, 128),
    "oldlace": (253, 245, 230),
    "olive": (128, 128, 0),
    "olivedrab": (107, 142, 35),
    "orange": (255, 165, 0),
    "orangered": (255, 69, 0),
    "orchid": (218, 112, 214),
    "palegoldenrod": (238, 232, 170),
    "palegreen": (152, 251, 152),
    "paleturquoise": (175, 238, 238),
    "palevioletred": (219, 112, 147),
    "papayawhip": (255, 239, 213),
    "peachpuff": (255, 218, 185),
    "peru": (205, 133, 63),
    "pink": (255, 192, 203),
    "plum": (221, 160, 221),
    "powderblue": (176, 224, 230),
    "purple": (128, 0, 128),
    "red": (255, 0, 0),
    "rosybrown": (188, 143, 143),
    "royalblue": (65, 105, 225),
    "saddlebrown": (139, 69, 19),
    "salmon": (250, 128, 114),
    "sandybrown": (244, 164, 96),
    "seagreen": (46, 139, 87),
    "seashell": (255, 245, 238),
    "sienna": (160, 82, 45),
    "silver": (192, 192, 192),
    "skyblue": (135, 206, 235),
    "slateblue": (106, 90, 205),
    "slategray": (112, 128, 144),
    "slategrey": (112, 128, 144),
    "snow": (255, 250, 250),
    "springgreen": (0, 255, 127),
    "steelblue": (70, 130, 180),
    "tan": (210, 180, 140),
    "teal": (0, 128, 128),
    "thistle": (216, 191, 216),
    "tomato": (255, 99, 71),
    "turquoise": (64, 224, 208),
    "violet": (238, 130, 238),
    "wheat": (245, 222, 179),
    "white": (255, 255, 255),
    "whitesmoke": (245, 245, 245),
    "yellow": (255, 255, 0),
    "yellowgreen": (154, 205, 50),
]
