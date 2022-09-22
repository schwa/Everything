import Foundation

public class BlockValueTransformer: ValueTransformer {
    public typealias TransformerBlock = (AnyObject?) -> (AnyObject?)

    public let block: TransformerBlock

    /*
    Generally used:

    BlockValueTransformer.register(name: "Foo") { return Foo($0) }
    }
    */
    public static func register(_ name: String, block: @escaping TransformerBlock) -> BlockValueTransformer {
        let transformer = BlockValueTransformer(block: block)
        setValueTransformer(transformer, forName: NSValueTransformerName(rawValue: name))
        return transformer
    }

    public init(block: @escaping TransformerBlock) {
        self.block = block
    }

    override public func transformedValue(_ value: Any?) -> Any? {
        block(value as AnyObject?)
    }
}
