import Domain

/**
 Class used in GraphQLClientWatcherWorkaround for proper cancellation handling when firing new watcher for stored handler
 */
class AnyReplaceableCancellableObject: CancellableObject {
    private var cancelHandler: () -> ()
    
    public init(cancel: @escaping () -> ()) {
        cancelHandler = cancel
    }
    
    func replaceCancel(_ cancel: @escaping () -> ()) {
        cancelHandler = cancel
    }
    
    func cancel() {
        cancelHandler()
    }
}
