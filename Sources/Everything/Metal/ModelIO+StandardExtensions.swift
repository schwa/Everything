import ModelIO

extension MDLMeshBufferType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .index:
            return "index"
        case .vertex:
            return "vertex"
        default:
            fatal(error: GeneralError.illegalValue)
        }
    }
}
