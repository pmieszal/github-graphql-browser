import Foundation

public enum QueryResult<Result> {
    case success(Result)
    case failure(LocalizedError)
    
    public var result: Result? {
        if case let .success(result) = self {
            return result
        }
        
        return nil
    }
    
    public var error: LocalizedError? {
        if case let .failure(error) = self {
            return error
        }
        
        return nil
    }
}
