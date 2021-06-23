import Foundation

public struct QueryResultEnvelope<TData> {
    let data: TData?
    let queryErrors: [LocalizedError]?
    
    public init(data: TData?, queryErrors: [LocalizedError]?) {
        self.data = data
        self.queryErrors = queryErrors
    }
}
