#if os(macOS)

    import Combine
    import Foundation

    public class FSEventPublisher: Publisher {
        public struct Event {
            public struct Flags: OptionSet, CustomStringConvertible {
                public let rawValue: Int

                public static let mustScanSubDirs = Flags(rawValue: kFSEventStreamEventFlagMustScanSubDirs)
                public static let userDropped = Flags(rawValue: kFSEventStreamEventFlagUserDropped)
                public static let kernelDropped = Flags(rawValue: kFSEventStreamEventFlagKernelDropped)
                public static let eventIdsWrapped = Flags(rawValue: kFSEventStreamEventFlagEventIdsWrapped)
                public static let historyDone = Flags(rawValue: kFSEventStreamEventFlagHistoryDone)
                public static let rootChanged = Flags(rawValue: kFSEventStreamEventFlagRootChanged)
                public static let mount = Flags(rawValue: kFSEventStreamEventFlagMount)
                public static let unmount = Flags(rawValue: kFSEventStreamEventFlagUnmount)
                public static let itemCreated = Flags(rawValue: kFSEventStreamEventFlagItemCreated)
                public static let itemRemoved = Flags(rawValue: kFSEventStreamEventFlagItemRemoved)
                public static let itemInodeMetaMod = Flags(rawValue: kFSEventStreamEventFlagItemInodeMetaMod)
                public static let itemRenamed = Flags(rawValue: kFSEventStreamEventFlagItemRenamed)
                public static let itemModified = Flags(rawValue: kFSEventStreamEventFlagItemModified)
                public static let itemFinderInfoMod = Flags(rawValue: kFSEventStreamEventFlagItemFinderInfoMod)
                public static let itemChangeOwner = Flags(rawValue: kFSEventStreamEventFlagItemChangeOwner)
                public static let itemXattrMod = Flags(rawValue: kFSEventStreamEventFlagItemXattrMod)
                public static let itemIsFile = Flags(rawValue: kFSEventStreamEventFlagItemIsFile)
                public static let itemIsDir = Flags(rawValue: kFSEventStreamEventFlagItemIsDir)
                public static let itemIsSymlink = Flags(rawValue: kFSEventStreamEventFlagItemIsSymlink)
                public static let ownEvent = Flags(rawValue: kFSEventStreamEventFlagOwnEvent)
                public static let itemIsHardlink = Flags(rawValue: kFSEventStreamEventFlagItemIsHardlink)
                public static let itemIsLastHardlink = Flags(rawValue: kFSEventStreamEventFlagItemIsLastHardlink)
                public static let itemCloned = Flags(rawValue: kFSEventStreamEventFlagItemCloned)

                public init(rawValue: Int) {
                    self.rawValue = rawValue
                }

                public var description: String {
                    let cases: [(Flags, String)] = [
                        (.mustScanSubDirs, "mustScanSubDirs"),
                        (.userDropped, "userDropped"),
                        (.kernelDropped, "kernelDropped"),
                        (.eventIdsWrapped, "eventIdsWrapped"),
                        (.historyDone, "historyDone"),
                        (.rootChanged, "rootChanged"),
                        (.mount, "mount"),
                        (.unmount, "unmount"),
                        (.itemCreated, "itemCreated"),
                        (.itemRemoved, "itemRemoved"),
                        (.itemInodeMetaMod, "itemInodeMetaMod"),
                        (.itemRenamed, "itemRenamed"),
                        (.itemModified, "itemModified"),
                        (.itemFinderInfoMod, "itemFinderInfoMod"),
                        (.itemChangeOwner, "itemChangeOwner"),
                        (.itemXattrMod, "itemXattrMod"),
                        (.itemIsFile, "itemIsFile"),
                        (.itemIsDir, "itemIsDir"),
                        (.itemIsSymlink, "itemIsSymlink"),
                        (.ownEvent, "ownEvent"),
                        (.itemIsHardlink, "itemIsHardlink"),
                        (.itemIsLastHardlink, "itemIsLastHardlink"),
                        (.itemCloned, "itemCloned"),
                    ]
                    return cases.filter { self.contains($0.0) }.map(\.1).joined(separator: ", ")
                }
            }

            public let flags: Flags
            public let path: String
            public let eventID: FSEventStreamEventId
            public let fileID: UInt64?
        }

        public typealias Output = [Event]
        public typealias Failure = Never
        typealias Subscription = ConcreteSubscription<Output, Failure>

        public let latency: TimeInterval
        public let queue: DispatchQueue
        var stream: FSEventStreamRef!
        var subscriptions: Set<Subscription> = []

        public struct Options: OptionSet {
            public let rawValue: Int
            public static let noDefer = Options(rawValue: kFSEventStreamCreateFlagNoDefer)
            public static let watchRoot = Options(rawValue: kFSEventStreamCreateFlagWatchRoot)
            public static let ignoreSelf = Options(rawValue: kFSEventStreamCreateFlagIgnoreSelf)
            public static let fileEvents = Options(rawValue: kFSEventStreamCreateFlagFileEvents)
            public static let markSelf = Options(rawValue: kFSEventStreamCreateFlagMarkSelf)

            public init(rawValue: Int) {
                self.rawValue = rawValue
            }
        }

        // swiftlint:disable:next line_length
        public init(paths: [String], latency: TimeInterval = 1, queue: DispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default), options: Options = [], lastEventID: FSEventStreamEventId = UInt64(kFSEventStreamEventIdSinceNow)) throws {
            self.latency = latency
            self.queue = queue

            var context = FSEventStreamContext()
            context.info = Unmanaged.passUnretained(self).toOpaque() // TODO: balance retain release
            let paths = paths as CFArray
            let flags = kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagUseExtendedData | options.rawValue

            stream = FSEventStreamCreate(kCFAllocatorDefault, _callback, &context, paths, lastEventID, latency, FSEventStreamCreateFlags(flags))

            FSEventStreamSetDispatchQueue(stream, queue)
            FSEventStreamStart(stream)
        }

        deinit {
            FSEventStreamStop(stream)
            FSEventStreamRelease(stream)
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            let subscription = Subscription(subscriber: subscriber, request: { _, _ in }, cancel: { [weak self] subscription in
                self?.subscriptions.remove(subscription)
            })
            subscriptions.insert(subscription)
            subscriber.receive(subscription: subscription)
        }

        func send(_ event: Output) {
            subscriptions.forEach {
                let demand = $0.subscriber.receive(event)
                assert(demand.max == 0 || demand.max == nil)
            }
        }

        func send(completion: Subscribers.Completion<Failure>) {
            subscriptions.forEach {
                $0.subscriber.receive(completion: completion)
            }
        }
    }

    // swiftlint:disable:next function_parameter_count line_length
    private func _callback(stream: ConstFSEventStreamRef, callbackInfo: UnsafeMutableRawPointer?, numEvents: Int, eventPaths: UnsafeMutableRawPointer, eventFlags: UnsafePointer<FSEventStreamEventFlags>, eventIds: UnsafePointer<FSEventStreamEventId>) {
        guard let callbackInfo else {
            return
        }
        let publisher = Unmanaged<FSEventPublisher>.fromOpaque(callbackInfo).takeUnretainedValue()
        let eventDictionaries = unsafeBitCast(eventPaths, to: NSArray.self) as! [NSDictionary]

        let events = eventDictionaries.enumerated().map { arg -> FSEventPublisher.Event in
            let (index, dictionary) = arg
            let flags = eventFlags[index]
            let eventID = eventIds[index]
            let path = dictionary[kFSEventStreamEventExtendedDataPathKey] as! String
            let fileID = dictionary[kFSEventStreamEventExtendedFileIDKey] as? UInt64
            return FSEventPublisher.Event(flags: .init(rawValue: Int(flags)), path: path, eventID: eventID, fileID: fileID)
        }
        publisher.send(events)
    }

#endif // os(macOS)
