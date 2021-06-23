import Foundation

public struct PagingErrorEnvelope {
    public var queryErrors: [LocalizedError]?
    public var networkError: LocalizedError?
    
    // SHORTCUT: not giving errors much thinking yet, just pass first query error or network error
    var error: LocalizedError? {
        queryErrors?.first ?? networkError
    }
    
    var hasErrors: Bool {
        queryErrors?.first != nil || networkError != nil
    }
    
    public init(queryErrors: [LocalizedError]?,
                networkError: LocalizedError? = nil) {
        self.queryErrors = queryErrors
        self.networkError = networkError
    }
}
