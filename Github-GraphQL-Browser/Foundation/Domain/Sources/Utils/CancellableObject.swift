import Foundation

/// An object that can be used to cancel an in progress action.
public protocol CancellableObject {
    /// Cancel an in progress action.
    func cancel()
}

public struct AnyCancellableObject: CancellableObject {
    private let cancelHandler: () -> ()
    
    public init(cancel: @escaping () -> ()) {
        cancelHandler = cancel
    }
    
    public func cancel() {
        cancelHandler()
    }
}
