import Metal
import SceneKit

public extension SCNGeometryPrimitiveType {
    init(_ type: MTLPrimitiveType) {
        switch type {
        case .triangle:
            self = .triangles
        default:
            fatal(error: GeneralError.illegalValue)
        }
    }
}
