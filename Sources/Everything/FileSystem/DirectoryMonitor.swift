#if os(macOS)

    import Foundation

    // TODO: Support combine/swift concurrency - deprecate
    public class DirectoryMonitor {
        public typealias Callback = (Directory, [FSPath]) -> Void

        public let latency: TimeInterval
        public let queue: DispatchQueue
        public var directories: [Directory] = [] {
            didSet {
                restart()
            }
        }

        public var callback: Callback? {
            didSet {
                restart()
            }
        }

        public var lastEventStreamEvent = UInt64(kFSEventStreamEventIdSinceNow)

        public private(set) var started = false
        private var stream: FSEventStreamRef?

        public init(latency: TimeInterval = 1, queue: DispatchQueue = DispatchQueue.main) {
            self.latency = latency
            self.queue = queue
        }

        deinit {
            queue.sync(flags: .barrier) {
                stop()
            }
        }

        struct Options: OptionSet {
            let rawValue: Int
            static let noDefer = Options(rawValue: kFSEventStreamCreateFlagNoDefer)
            static let WatchRoot = Options(rawValue: kFSEventStreamCreateFlagWatchRoot)
            static let IgnoreSelf = Options(rawValue: kFSEventStreamCreateFlagIgnoreSelf)
            static let FileEvents = Options(rawValue: kFSEventStreamCreateFlagFileEvents)
            static let MarkSelf = Options(rawValue: kFSEventStreamCreateFlagMarkSelf)
        }

        public func start() {
            guard started == false else {
                return
            }

            if directories.isEmpty == true {
                started = true
                return
            }

            var context = FSEventStreamContext()

            context.info = Unmanaged.passUnretained(self).toOpaque()
            // TODO: retain release

            let paths = directories.map(\.path.path)

            let flags = kFSEventStreamCreateFlagNoDefer | kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagIgnoreSelf | kFSEventStreamCreateFlagFileEvents

            guard let stream = FSEventStreamCreate(kCFAllocatorDefault, _callback, &context, paths as CFArray, lastEventStreamEvent, latency, FSEventStreamCreateFlags(flags)) else {
                unimplemented() // TODO: now what?
            }

            FSEventStreamSetDispatchQueue(stream, queue)
            FSEventStreamStart(stream)

            self.stream = stream
            started = true
        }

        public func stop() {
            guard started == true else {
                return
            }
            if let stream {
                FSEventStreamStop(stream)
                self.stream = nil
            }
            started = false
        }

        private func restart() {
            guard started == true else {
                return
            }

            stop()
            start()
        }

        private func pausing(_ action: () -> Void) {
            if started == true {
                stop()
                action()
                start()
            }
            else {
                action()
            }
        }
    }

    // swiftlint:disable:next function_parameter_count line_length
    private func _callback(stream _: ConstFSEventStreamRef, callbackInfo: UnsafeMutableRawPointer?, numEvents: Int, eventPaths: UnsafeMutableRawPointer, eventFlags _: UnsafePointer<FSEventStreamEventFlags>, eventIds: UnsafePointer<FSEventStreamEventId>) {
        guard let callbackInfo = callbackInfo else {
            return
        }
        let directoryMonitor = Unmanaged<DirectoryMonitor>.fromOpaque(callbackInfo).takeUnretainedValue()

        guard let callback = directoryMonitor.callback else {
            return
        }

        let eventPaths = unsafeBitCast(eventPaths, to: NSArray.self) as! [String]

        warning("\(eventPaths)")
        let directories = directoryMonitor.directories.sorted()
        var pathIterator = eventPaths.map { FSPath(path: $0) }.sorted().makeIterator()

        var path: FSPath! = pathIterator.next()

        for directory in directories {
            var pathsForDirectory: [FSPath] = []
            while path != nil, path.hasPrefix(directory.path) {
                pathsForDirectory.append(path)
                path = pathIterator.next()
            }
            if pathsForDirectory.isEmpty == false {
                callback(directory, pathsForDirectory)
            }
        }

        let eventIDsBuffer = UnsafeBufferPointer(start: eventIds, count: numEvents)
        for eventID in eventIDsBuffer {
            directoryMonitor.lastEventStreamEvent = max(directoryMonitor.lastEventStreamEvent, eventID)
        }
    }

#endif
