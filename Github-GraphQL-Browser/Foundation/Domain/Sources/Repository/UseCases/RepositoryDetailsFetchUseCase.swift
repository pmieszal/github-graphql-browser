import Foundation

public class RepositoryDetailsFetchUseCase {
    let service: RepositoryDetailsService
    let itemsCount: Int
    var fetchCancellable: CancellableObject?
    
    public init(service: RepositoryDetailsService,
                itemsCount: Int) {
        self.service = service
        self.itemsCount = itemsCount
    }
    
    public func fetchDetails(owner: String,
                             name: String,
                             handler: ((RepositoryDetailsState) -> ())?) {
        let query = RepositoryDetailsQuery(
            owner: owner,
            name: name,
            issuesCount: itemsCount,
            pullRequestsCount: itemsCount)
        
        fetchCancellable?.cancel()
        fetchCancellable = service.fetchQuery(
            query,
            completion: { result in
                /*
                 SHORTCUT: this is shortcut for passing events on main queue,
                 ideally this should be handled by separate mechanism, or separate layer between Domain and UI
                 */
                
                DispatchQueue.main.async {
                    switch result {
                    case let .success(result):
                        handler?(RepositoryDetailsState(
                            details: result.data,
                            // SHORTCUT: not giving errors much thinking yet, just pass first error
                            error: result.queryErrors?.first))
                    case let .failure(error):
                        handler?(RepositoryDetailsState(details: nil, error: error))
                    }
                }
            })
    }
}
