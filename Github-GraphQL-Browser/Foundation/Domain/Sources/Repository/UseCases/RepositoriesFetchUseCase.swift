import Foundation

/**
 Super simple use case for the simples repositories fetch. Not used anymore, in favour of RepositoriesWatchUseCase.
 */
public class RepositoriesFetchUseCase {
    private let service: RepositoriesService
    var fetchCancellable: CancellableObject?
    
    public init(service: RepositoriesService) {
        self.service = service
    }
    
    public func fetch(owner: String, handler: (([Repository]) -> ())?) {
        let query = RepositoriesQuery(owner: owner, count: 20, after: nil)
        
        fetchCancellable?.cancel()
        fetchCancellable = service.refreshQuery(query, completion: { result in
            /*
             SHORTCUT: this is shortcut for passing events on main queue,
             ideally this should be handled by separate mechanism, or separate layer between Domain and UI
             */
            DispatchQueue.main.async {
                handler?(result.result?.pageableEnvelope.data ?? [])
            }
        })
    }
}
