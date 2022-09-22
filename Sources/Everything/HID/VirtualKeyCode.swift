// swiftlint:disable file_length

#if os(macOS)
import AppKit

public class KeyboardState {
    public static let shared = KeyboardState()

    @Published
    public var rawKeysDown: Set<UInt16> = []

    public var keysDown: Set<VirtualKeyCode> {
        Set(rawKeysDown.compactMap(VirtualKeyCode.init))
    }

    private var monitor: Any?

    init() {
    }

    func installLocalMonitor() {
        guard monitor == nil else {
            return
        }
        monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp, .flagsChanged]) { event in
            self.handle(event: event)
            return event
        }
    }

    func removeLocalMonitor() {
        guard let monitor = monitor else {
            return
        }
        NSEvent.removeMonitor(monitor)
        self.monitor = nil
    }

    public func handle(event: NSEvent) {
        switch event.type {
        case .keyUp:
            rawKeysDown.remove(event.keyCode)
        case .keyDown:
            rawKeysDown.insert(event.keyCode)
        default:
            break
        }
    }

    public func keyDown(_ key: VirtualKeyCode) -> Bool {
        rawKeysDown.contains(key.rawValue)
    }

    public func areKeysDown(_ keys: Set<VirtualKeyCode>) -> Bool {
        rawKeysDown.isSuperset(of: keys.map(\.rawValue))
    }
}

/*  Summary:
 *    Virtual keycodes
 *
 *  Discussion:
 *    These constants are the virtual keycodes defined originally in
 *    Inside Mac Volume V, pg. V-191. They identify physical keys on a
 *    keyboard. Those constants with "ANSI" in the name are labeled
 *    according to the key position on an ANSI-standard US keyboard.
 *    For example, ANSI_A indicates the virtual keycode for the key
 *    with the letter 'A' in the US keyboard layout. Other keyboard
 *    layouts may have the 'A' key label on a different physical key;
 *    in this case, pressing 'A' will generate a different virtual
 *    keycode.
 */
public enum VirtualKeyCode: UInt16, CaseIterable, Sendable {
    case ANSI_0 = 0x1D
    case ANSI_1 = 0x12
    case ANSI_2 = 0x13
    case ANSI_3 = 0x14
    case ANSI_4 = 0x15
    case ANSI_5 = 0x17
    case ANSI_6 = 0x16
    case ANSI_7 = 0x1A
    case ANSI_8 = 0x1C
    case ANSI_9 = 0x19
    case ANSI_A = 0x00
    case ANSI_B = 0x0B
    case ANSI_C = 0x08
    case ANSI_D = 0x02
    case ANSI_E = 0x0E
    case ANSI_F = 0x03
    case ANSI_G = 0x05
    case ANSI_H = 0x04
    case ANSI_I = 0x22
    case ANSI_J = 0x26
    case ANSI_K = 0x28
    case ANSI_L = 0x25
    case ANSI_M = 0x2E
    case ANSI_N = 0x2D
    case ANSI_O = 0x1F
    case ANSI_P = 0x23
    case ANSI_Q = 0x0C
    case ANSI_R = 0x0F
    case ANSI_S = 0x01
    case ANSI_T = 0x11
    case ANSI_U = 0x20
    case ANSI_V = 0x09
    case ANSI_W = 0x0D
    case ANSI_X = 0x07
    case ANSI_Y = 0x10
    case ANSI_Z = 0x06
    case ANSI_Backslash = 0x2A
    case ANSI_Comma = 0x2B
    case ANSI_Equal = 0x18
    case ANSI_Grave = 0x32
    case ANSI_Keypad0 = 0x52
    case ANSI_Keypad1 = 0x53
    case ANSI_Keypad2 = 0x54
    case ANSI_Keypad3 = 0x55
    case ANSI_Keypad4 = 0x56
    case ANSI_Keypad5 = 0x57
    case ANSI_Keypad6 = 0x58
    case ANSI_Keypad7 = 0x59
    case ANSI_Keypad8 = 0x5B
    case ANSI_Keypad9 = 0x5C
    case ANSI_KeypadClear = 0x47
    case ANSI_KeypadDecimal = 0x41
    case ANSI_KeypadDivide = 0x4B
    case ANSI_KeypadEnter = 0x4C
    case ANSI_KeypadEquals = 0x51
    case ANSI_KeypadMinus = 0x4E
    case ANSI_KeypadMultiply = 0x43
    case ANSI_KeypadPlus = 0x45
    case ANSI_LeftBracket = 0x21
    case ANSI_Minus = 0x1B
    case ANSI_Period = 0x2F
    case ANSI_Quote = 0x27
    case ANSI_RightBracket = 0x1E
    case ANSI_Semicolon = 0x29
    case ANSI_Slash = 0x2C

    /* keycodes for keys that are independent of keyboard layout*/
    case F1 = 0x7A
    case F2 = 0x78
    case F3 = 0x63
    case F4 = 0x76
    case F5 = 0x60
    case F6 = 0x61
    case F7 = 0x62
    case F8 = 0x64
    case F9 = 0x65
    case F10 = 0x6D
    case F11 = 0x67
    case F12 = 0x6F
    case F13 = 0x69
    case F14 = 0x6B
    case F15 = 0x71
    case F16 = 0x6A
    case F17 = 0x40
    case F18 = 0x4F
    case F19 = 0x50
    case F20 = 0x5A
    case CapsLock = 0x39
    case Command = 0x37
    case Control = 0x3B
    case Delete = 0x33
    case DownArrow = 0x7D
    case End = 0x77
    case Escape = 0x35
    case ForwardDelete = 0x75
    case Function = 0x3F
    case Help = 0x72
    case Home = 0x73
    case LeftArrow = 0x7B
    case Mute = 0x4A
    case Option = 0x3A
    case PageDown = 0x79
    case PageUp = 0x74
    case Return = 0x24
    case RightArrow = 0x7C
    case RightCommand = 0x36
    case RightControl = 0x3E
    case RightOption = 0x3D
    case RightShift = 0x3C
    case Shift = 0x38
    case Space = 0x31
    case Tab = 0x30
    case UpArrow = 0x7E
    case VolumeDown = 0x49
    case VolumeUp = 0x48

    /* ISO keyboards only*/
    case ISO_Section = 0x0A

    /* JIS keyboards only*/
    case JIS_Yen = 0x5D
    case JIS_Underscore = 0x5E
    case JIS_KeypadComma = 0x5F
    case JIS_Eisu = 0x66
    case JIS_Kana = 0x68
}

// swiftlint:disable switch_case_on_newline
extension VirtualKeyCode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .ANSI_0: return "0"
        case .ANSI_1: return "1"
        case .ANSI_2: return "2"
        case .ANSI_3: return "3"
        case .ANSI_4: return "4"
        case .ANSI_5: return "5"
        case .ANSI_6: return "6"
        case .ANSI_7: return "7"
        case .ANSI_8: return "8"
        case .ANSI_9: return "9"
        case .ANSI_A: return "A"
        case .ANSI_B: return "B"
        case .ANSI_C: return "C"
        case .ANSI_D: return "D"
        case .ANSI_E: return "E"
        case .ANSI_F: return "F"
        case .ANSI_G: return "G"
        case .ANSI_H: return "H"
        case .ANSI_I: return "I"
        case .ANSI_J: return "J"
        case .ANSI_K: return "K"
        case .ANSI_L: return "L"
        case .ANSI_M: return "M"
        case .ANSI_N: return "N"
        case .ANSI_O: return "O"
        case .ANSI_P: return "P"
        case .ANSI_Q: return "Q"
        case .ANSI_R: return "R"
        case .ANSI_S: return "S"
        case .ANSI_T: return "T"
        case .ANSI_U: return "U"
        case .ANSI_V: return "V"
        case .ANSI_W: return "W"
        case .ANSI_X: return "X"
        case .ANSI_Y: return "Y"
        case .ANSI_Z: return "Z"
        case .ANSI_Backslash: return "\\"
        case .ANSI_Comma: return ","
        case .ANSI_Equal: return "="
        case .ANSI_Grave: return "`"
        case .ANSI_Keypad0: return "KP0"
        case .ANSI_Keypad1: return "KP1"
        case .ANSI_Keypad2: return "KP2"
        case .ANSI_Keypad3: return "KP3"
        case .ANSI_Keypad4: return "KP4"
        case .ANSI_Keypad5: return "KP5"
        case .ANSI_Keypad6: return "KP6"
        case .ANSI_Keypad7: return "KP7"
        case .ANSI_Keypad8: return "KP8"
        case .ANSI_Keypad9: return "KP9"
        case .ANSI_KeypadClear: return "Clear"
        case .ANSI_KeypadDecimal: return "."
        case .ANSI_KeypadDivide: return "/"
        case .ANSI_KeypadEnter: return "Enter"
        case .ANSI_KeypadEquals: return "="
        case .ANSI_KeypadMinus: return "-"
        case .ANSI_KeypadMultiply: return "KP*"
        case .ANSI_KeypadPlus: return "KP+"
        case .ANSI_LeftBracket: return "["
        case .ANSI_Minus: return "-"
        case .ANSI_Period: return "."
        case .ANSI_Quote: return "\""
        case .ANSI_RightBracket: return "]"
        case .ANSI_Semicolon: return ";"
        case .ANSI_Slash: return "/"

            /* keycodes for keys that are independent of keyboard layout*/
        case .F1: return "F1"
        case .F2: return "F2"
        case .F3: return "F3"
        case .F4: return "F4"
        case .F5: return "F5"
        case .F6: return "F6"
        case .F7: return "F7"
        case .F8: return "F8"
        case .F9: return "F9"
        case .F10: return "F10"
        case .F11: return "F11"
        case .F12: return "F12"
        case .F13: return "F13"
        case .F14: return "F14"
        case .F15: return "F15"
        case .F16: return "F16"
        case .F17: return "F17"
        case .F18: return "F18"
        case .F19: return "F19"
        case .F20: return "F20"
        case .CapsLock: return "CapsLock"
        case .Command: return "Command"
        case .Control: return "Control"
        case .Delete: return "Delete"
        case .DownArrow: return "DownArrow"
        case .End: return "End"
        case .Escape: return "Escape"
        case .ForwardDelete: return "ForwardDelete"
        case .Function: return "Function"
        case .Help: return "Help"
        case .Home: return "Home"
        case .LeftArrow: return "LeftArrow"
        case .Mute: return "Mute"
        case .Option: return "Option"
        case .PageDown: return "PageDown"
        case .PageUp: return "PageUp"
        case .Return: return "Return"
        case .RightArrow: return "RightArrow"
        case .RightCommand: return "RightCommand"
        case .RightControl: return "RightControl"
        case .RightOption: return "RightOption"
        case .RightShift: return "RightShift"
        case .Shift: return "Shift"
        case .Space: return "Space"
        case .Tab: return "Tab"
        case .UpArrow: return "UpArrow"
        case .VolumeDown: return "VolumeDown"
        case .VolumeUp: return "VolumeUp"

            /* ISO keyboards only*/
        case .ISO_Section: return "ISO_Section"

            /* JIS keyboards only*/
        case .JIS_Yen: return "JIS_Yen"
        case .JIS_Underscore: return "JIS_Underscore"
        case .JIS_KeypadComma: return "JIS_KeypadComma"
        case .JIS_Eisu: return "JIS_Eisu"
        case .JIS_Kana: return "JIS_Kana"
        }
    }
}

#endif // os(macOS)
