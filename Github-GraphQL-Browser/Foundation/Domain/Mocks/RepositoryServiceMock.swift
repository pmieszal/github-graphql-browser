import Domain
import Foundation

class RepositoryServiceMock: RepositoriesService {
    private var watchEvents = [PageableEnvelope<[Repository]>]()
    private var refreshEvents = [QueryResult<QueryPageableResultEnvelope<[Repository]>>]()
    
    func appendWatchResult(_ result: PageableEnvelope<[Repository]>) {
        watchEvents.append(result)
    }
    
    func appendRefreshResult(_ result: QueryResult<QueryPageableResultEnvelope<[Repository]>>) {
        refreshEvents.append(result)
    }
    
    func watchChangesForQuery(_ query: RepositoriesQuery,
                              handler: ((PageableEnvelope<[Repository]>) -> ())?) -> CancellableObject {
        guard watchEvents.isEmpty == false else {
            return DummyCancellable()
        }
        
        let event = watchEvents.removeFirst()
        
        DispatchQueue.main.async {
            handler?(event)
        }
        
        return DummyCancellable()
    }
    
    func refreshQuery(_ query: RepositoriesQuery,
                      completion: ((QueryResult<QueryPageableResultEnvelope<[Repository]>>) -> ())?) -> CancellableObject {
        guard refreshEvents.isEmpty == false else {
            return DummyCancellable()
        }
        
        let event = refreshEvents.removeFirst()
        
        DispatchQueue.main.async {
            completion?(event)
        }
        
        return DummyCancellable()
    }
}
