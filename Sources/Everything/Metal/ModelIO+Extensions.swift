// import Foundation
// import ModelIO
//
// public extension MDLVertexDescriptor {
//    func toCode() throws -> String {
//        let attributes = self.attributes.map { $0 as! MDLVertexAttribute }.filter { $0.format != .invalid }
//        let attributesByBuffer = Array(Dictionary(grouping: attributes) { ($0.bufferIndex) }).sorted { $0.0 < $1.0 }
//        let s = attributesByBuffer.flatMap { buffer, attributes -> [String] in
//            let attributes = attributes.sorted { $0.offset < $1.offset }
//            let structName = attributesByBuffer.count > 1 ? "Vertex_\(buffer)" : "Vertex"
//            return ["// buffer: \(buffer)", "struct \(structName) {"] + attributes.map { attribute in
//                "\(attribute.format) \(attribute.name); // offset: \(attribute.offset)"
//            }
//            .indented() + ["};"]
//        }
//        return s.joined(separator: "\n")
//    }
// }
//
// public extension MDLMeshBufferAllocator {
//    func newVertexBuffer(with points: [CGPoint]) -> MDLMeshBuffer {
//        let vertices = points.map {
//            SIMD2<Float>($0)
//        }
//        let data = vertices.withUnsafeBytes { bytes in
//            Data(bytes)
//        }
//        return newBuffer(with: data, type: .vertex)
//    }
//
//    func newIndexBuffer(with indices: [UInt8]) -> MDLMeshBuffer {
//        let data = Data(indices)
//        return newBuffer(with: data, type: .index)
//    }
// }
