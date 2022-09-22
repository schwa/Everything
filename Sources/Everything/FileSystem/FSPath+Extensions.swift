import Foundation

public extension FSPath {
    func rotate(limit: Int? = nil) throws {
        guard exists else {
            return
        }
        guard let parent = parent else {
            throw GeneralError.generic("No parent")
        }
        let destination: FSPath
        if let index = Int(pathExtension) {
            destination = parent + (stem + ".\(index + 1)")
            if let limit {
                if index >= limit, exists {
                    try remove()
                    return
                }
            }
        }
        else {
            destination = parent + (name + ".1")
        }
        try destination.rotate(limit: limit)
        try move(destination)
    }
}

public extension Bundle {
    var resourceFSPath: FSPath? {
        resourceURL.map { FSPath($0) }
    }
}
