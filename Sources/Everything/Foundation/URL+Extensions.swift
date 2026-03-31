import Foundation

public extension URL {
    func URLByResolvingURL() throws -> URL {
        let bookmarkData = try (self as NSURL).bookmarkData(options: NSURL.BookmarkCreationOptions.minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
        return try (NSURL(resolvingBookmarkData: bookmarkData, options: .withoutUI, relativeTo: nil, bookmarkDataIsStale: nil) as URL)
    }

    static func + (lhs: URL, rhs: String) -> URL {
        lhs.appendingPathComponent(rhs)
    }

    static func += (left: inout URL, right: String) {
        left = left.appendingPathComponent(right)
    }
}
