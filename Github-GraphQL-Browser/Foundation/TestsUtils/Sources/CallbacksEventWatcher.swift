import XCTest

/**
 This class is an experiment to fix nested callbacks when doing tests.
 Not properly tested 😅 Using on your own risk!
 There are times when it produce flaky test, sometimes when simulator is doing cold start
 (that's why timeouts are set to 10 seconds by default).
 */
@available(*, deprecated, message: "Deprecated in favour of Watcher build on top of Nimble")
public class CallbacksEventWatcher<Value> {
    public private(set) var values = [Value]()
    private var expectation: XCTestExpectation?
    private let testCase: XCTestCase
    
    public var lastValue: Value? {
        values.last
    }
    
    init(testCase: XCTestCase) {
        self.testCase = testCase
    }
    
    func watch() -> (Value) -> () {
        return { value in
            self.values.append(value)
            self.expectation?.fulfill()
            self.expectation = nil
        }
    }
    
    public func waitForNextValue(timeout: TimeInterval = 10) -> Value? {
        let expectation = testCase.expectation(description: "Expect value")
        self.expectation = expectation
        
        testCase.wait(for: [expectation], timeout: timeout)
        
        return lastValue
    }
    
    public func expectToNotBeInvoked(timeout: TimeInterval = 10) {
        let expectation = testCase.expectation(description: "Expect to be invoked once")
        self.expectation = expectation
        
        // Expectation will fail if expectation will be invoked more than 2 times
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: expectation.fulfill)
        
        testCase.wait(for: [expectation], timeout: timeout)
    }
}

private extension XCTestCase {
    @available(*, deprecated, message: "Deprecated in favour of Watcher build on top of Nimble")
    func watchCallbackEvents<Value>(_ handler: (@escaping (Value) -> ()) -> ()) -> CallbacksEventWatcher<Value> {
        let watcher = CallbacksEventWatcher<Value>(testCase: self)
        handler(watcher.watch())

        return watcher
    }
    
    @available(*, deprecated, message: "Deprecated in favour of Watcher build on top of Nimble")
    func waitForCallback<Value>(timeout: TimeInterval = 10,
                                handler: (((Value) -> ())?) -> ()) -> Value {
        var result: Value!
        let expectResult = expectation(description: "Expect result")

        handler { value in
            result = value
            expectResult.fulfill()
        }

        wait(for: [expectResult], timeout: timeout)

        return result
    }
}
