import Foundation

public func benchmark(closure: () -> Void) -> TimeInterval {
    let start = mach_absolute_time()
    closure()
    let end = mach_absolute_time()

    var info = mach_timebase_info_data_t()
    if mach_timebase_info(&info) != 0 {
        unimplemented()
    }
    let nanos = (end - start) * UInt64(info.numer) / UInt64(info.denom)
    return TimeInterval(nanos) / TimeInterval(NSEC_PER_SEC)
}
