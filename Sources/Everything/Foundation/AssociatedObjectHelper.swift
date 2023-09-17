import Foundation

/**
 Type-safe helper for objc Associated Objects

 ```
 // Create a _global_ helper instance. Of the type you want to store in your objact
 private let helper = AssociatedObjectHelper <Float> ()

 // Create your object.
 let object = NSObject()

 // Use the associated helper to set and get values on your objects
 helper.setAssociatedValueForObject(object, 3.14)
 helper.getAssociatedValueForObject(object) // 3.14

 let object2 = NSObject()
 helper.getAssociatedValueForObject(object) // nil
 ```
 */
@available(*, deprecated, message: "Deprecated")
public final class AssociatedObjectHelper<T> {
    public let policy: objc_AssociationPolicy

    public init(atomic: Bool = true) {
        policy = atomic ? .OBJC_ASSOCIATION_RETAIN : .OBJC_ASSOCIATION_RETAIN_NONATOMIC
    }

    // swiftlint:disable:next unavailable_function
    deinit {
        fatalError("Associated Helpers should not deinit")
    }

    public func getAssociatedValueForObject(_ object: AnyObject) -> T? {
        guard let associatedObject = objc_getAssociatedObject(object, key) else {
            return nil
        }
        if T.self == AnyObject.self {
            return associatedObject as? T
        }
        else if let box = associatedObject as? Box<T> {
            return box.value
        }
        else {
            fatalError("How did we get here?")
        }
    }

    public func setAssociatedValueForObject(_ object: AnyObject, value: T?) {
        let associatedObject: AnyObject?
        if let value {
            if T.self == AnyObject.self {
                associatedObject = value as AnyObject
            }
            else {
                associatedObject = Box(value)
            }
        }
        else {
            associatedObject = nil
        }
        objc_setAssociatedObject(object, key, associatedObject, policy)
    }

    public func deleteAssociatedValueForObject(_ object: AnyObject) {
        var key = self
        objc_setAssociatedObject(object, &key, nil, policy)
    }

    private var key: UnsafeRawPointer {
        UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
    }
}
