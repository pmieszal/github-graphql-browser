import Foundation

public struct QueryPageableResultEnvelope<TData: Hashable> {
    let pageableEnvelope: PageableEnvelope<TData>
    let queryErrors: [LocalizedError]?
    
    public init(pageableEnvelope: PageableEnvelope<TData>, queryErrors: [LocalizedError]?) {
        self.pageableEnvelope = pageableEnvelope
        self.queryErrors = queryErrors
    }
}
