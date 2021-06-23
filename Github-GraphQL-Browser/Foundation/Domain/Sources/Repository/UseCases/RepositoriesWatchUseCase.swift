import Foundation

public class RepositoriesWatchUseCase {
    private let service: RepositoriesService
    private let paging: Paging<[Repository]>
    
    public init(service: RepositoriesService,
                pageItemsCount: Int) {
        self.service = service
        paging = Paging(pageItemsCount: pageItemsCount)
    }
    
    public func watchRepositoriesForOwner(owner: String,
                                          stateEventsHandler: ((RepositoriesListState) -> ())?) {
        paging.start(
            eventsCallback: { state in
                let repositories = state.data?.joined().compactMap { $0 } ?? []
                let state = RepositoriesListState(
                    list: repositories,
                    // SHORTCUT: not giving errors much thinking yet, just pass first error
                    error: state.errors?.error,
                    isLoading: state.isLoading)
                
                /*
                 SHORTCUT: this is shortcut for passing events on main queue,
                 ideally this should be handled by separate mechanism, or separate layer between Domain and UI
                 */
                DispatchQueue.main.async {
                    stateEventsHandler?(state)
                }
            },
            watcherFactory: { [weak self] pageQueryInfo, callback in
                let query = RepositoriesQuery(
                    owner: owner,
                    count: pageQueryInfo.pageItemsCount,
                    after: pageQueryInfo.lastPageInfo?.endCursor)
            
                return PageWatcher(
                    id: query,
                    dataChangeCallback: callback,
                    watchDataFactory: { [weak self] handler in
                        self?.service.watchChangesForQuery(query, handler: handler) ?? AnyCancellableObject(cancel: {})
                    },
                    fetchDataFactory: { [weak self] completion in
                        self?.service.refreshQuery(query, completion: completion) ?? AnyCancellableObject(cancel: {})
                    })
            })
    }
    
    public func loadNextPage() {
        paging.requestNextPage()
    }
    
    public func unsubscribe() {
        paging.unsubscribe()
    }
}
