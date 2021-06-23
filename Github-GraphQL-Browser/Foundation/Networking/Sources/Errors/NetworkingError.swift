import Foundation

public enum NetworkingError: LocalizedError {
    case url(error: URLError)
    case unknown(error: Error)
    
    init(error: Error) {
        if let urlError = error as? URLError {
            self = .url(error: urlError)
        }
        
        self = .unknown(error: error)
    }
    
    public var errorDescription: String? {
        switch self {
        case let .url(error):
            return error.localizedDescription
        case let .unknown(error):
            return error.localizedDescription
        }
    }
}
