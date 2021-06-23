import Foundation

public extension Result {
    var success: Success? {
        if case let .success(result) = self {
            return result
        }
        
        return nil
    }
    
    var error: Error? {
        if case let .failure(error) = self {
            return error
        }
        
        return nil
    }
}
