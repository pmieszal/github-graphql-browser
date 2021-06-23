import Apollo
import Foundation

public class URLSessionClientMock: URLSessionClient {
    private var results = [Result<(Data, HTTPURLResponse), Error>]()
    
    public func appendResult(_ result: Result<(Data, HTTPURLResponse), Error>) {
        results.append(result)
    }
    
    override public func sendRequest(_ request: URLRequest,
                                     rawTaskCompletionHandler: URLSessionClient.RawCompletion? = nil,
                                     completion: @escaping URLSessionClient.Completion) -> URLSessionTask {
        guard results.isEmpty == false else {
            return URLSessionTaskMock()
        }
        
        let response = results.removeFirst()
        
        DispatchQueue.global().async {
            completion(response)
        }
        
        return URLSessionTaskMock()
    }
}

// Dummy subclass to suppress deprecated init warning
class URLSessionTaskMock: URLSessionTask {
    override init() {}
}
