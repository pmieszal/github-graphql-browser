import Foundation
import Nimble
import Quick
import XCTest

public class Watcher<Value> {
    typealias Callback = (@escaping (Value) -> ()) -> ()
    public private(set) var values = [Value]()
    
    public var lastValue: Value? {
        values.last
    }
    
    func watch() -> (Value) -> () {
        return { value in
            self.values.append(value)
        }
    }
    
    @available(*, deprecated, message: "use expectEventsCount")
    public func waitForNextValue(timeout: DispatchTimeInterval = AsyncDefaults.timeout,
                                 file: FileString = #file,
                                 line: UInt = #line) -> Value? {
        let previousCount = values.count
        var result: Value?
        
        waitUntil(timeout: timeout, file: file, line: line) { done in
            Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
                if self.values.count >= previousCount {
                    result = self.values.last
                    done()
                    timer.invalidate()
                    return
                }
            }
        }
        
        return result
    }
    
    public func expectEventsCount(_ count: Int,
                                  timeoutSeconds: Int = 2,
                                  file: FileString = #file,
                                  line: UInt = #line) {
        if values.count >= count {
            return
        }
        
        waitUntil(timeout: .seconds(timeoutSeconds), file: file, line: line) { done in
            Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
                if self.values.count == count {
                    done()
                    timer.invalidate()
                    return
                }
            }
        }
    }
    
    public func expectToNotBeInvoked(duration: TimeInterval = 2,
                                     file: FileString = #file,
                                     line: UInt = #line) {
        let previousCount = values.count
        
        let runLoop = RunLoop.current
        let timeoutDate = Date(timeIntervalSinceNow: duration)
        repeat {
            if values.count != previousCount {
                XCTFail("Expected to not be invoked", file: file, line: line)
                return
            }
            runLoop.run(until: Date(timeIntervalSinceNow: 0.01))
        } while Date().compare(timeoutDate) == .orderedAscending
    }
}

public func watchCallbackEvents<Value>(_ callback: @escaping (@escaping (Value) -> ()) -> ()) -> Watcher<Value> {
    let watcher = Watcher<Value>()
    callback(watcher.watch())
    
    return watcher
}

public func waitForCallback<Value>(timeout: DispatchTimeInterval = AsyncDefaults.timeout,
                                   file: FileString = #file,
                                   line: UInt = #line,
                                   handler: @escaping (((Value) -> ())?) -> ()) -> Value? {
    var result: Value?
        
    waitUntil(timeout: timeout, file: file, line: line) { done in
        handler {
            result = $0
            done()
        }
    }
        
    return result
}
