import Domain
import Foundation

class RepositoryDetailsServiceMock: RepositoryDetailsService {
    private var fetchEvents = [QueryResult<QueryResultEnvelope<RepositoryDetails>>]()
    
    func appendFetchResult(_ result: QueryResult<QueryResultEnvelope<RepositoryDetails>>) {
        fetchEvents.append(result)
    }
    
    func fetchQuery(_ query: RepositoryDetailsQuery,
                    completion: ((QueryResult<QueryResultEnvelope<RepositoryDetails>>) -> ())?) -> CancellableObject {
        guard fetchEvents.isEmpty == false else {
            return DummyCancellable()
        }
        
        let event = fetchEvents.removeFirst()
        
        DispatchQueue.main.async {
            completion?(event)
        }
        
        return DummyCancellable()
    }
}
