import CoreVideo
import Foundation

public extension CVTimeStamp {
    var seconds: TimeInterval {
        TimeInterval(videoTime) * TimeInterval(videoTimeScale)
    }
}

public class MachTime {
    public var timebase = mach_timebase_info_data_t()

    public init() {
        if mach_timebase_info(&timebase) != 0 {
            unimplemented()
        }
    }

    public func currentNanos() -> UInt64 {
        mach_absolute_time() * UInt64(timebase.numer) / UInt64(timebase.denom)
    }

    public func current() -> TimeInterval {
        TimeInterval(currentNanos()) / TimeInterval(NSEC_PER_SEC)
    }

    public func elapsed(_ f: () -> Void) -> TimeInterval {
        let start = currentNanos()
        f()
        let end = currentNanos()
        return TimeInterval(end - start) / TimeInterval(NSEC_PER_SEC)
    }
}
