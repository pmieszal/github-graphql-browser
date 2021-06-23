import Foundation

class PageWatcher<TData: Hashable>: Equatable {
    typealias PageResult = PageableEnvelope<TData>
    typealias FetchResult = QueryResult<QueryPageableResultEnvelope<TData>>
    typealias WatchDataFactory = (((PageResult) -> ())?) -> (CancellableObject)
    typealias FetchDataFactory = (((FetchResult) -> ())?) -> (CancellableObject)
    
    private let dataChangeCallback: (() -> ())?
    private let watchDataFactory: WatchDataFactory?
    private let fetchDataFactory: FetchDataFactory?
    private var watchCancel: CancellableObject?
    private var fetchCancel: CancellableObject?
    
    private(set) var lastResult: PageResult?
    private(set) var isLoading = false
    private(set) var lastError: PagingErrorEnvelope?
    
    let id: AnyHashable
    
    init(id: AnyHashable,
         dataChangeCallback: (() -> ())?,
         watchDataFactory: WatchDataFactory?,
         fetchDataFactory: FetchDataFactory?) {
        self.id = id
        self.dataChangeCallback = dataChangeCallback
        self.watchDataFactory = watchDataFactory
        self.fetchDataFactory = fetchDataFactory
    }
    
    func watch() {
        watchCancel?.cancel()
        watchCancel = watchDataFactory?({ [weak self] result in
            self?.notifyWatch(result)
        })
    }
    
    func fetch(_ completion: (() -> ())? = nil) {
        isLoading = true
        fetchCancel?.cancel()
        fetchCancel = fetchDataFactory?({ [weak self] result in
            self?.notifyFetch(result)
            completion?()
        })
    }
    
    func cancel() {
        watchCancel?.cancel()
        fetchCancel?.cancel()
        watchCancel = nil
        fetchCancel = nil
    }
    
    static func == (lhs: PageWatcher<TData>, rhs: PageWatcher<TData>) -> Bool {
        lhs.id == rhs.id
    }
}

private extension PageWatcher {
    func notifyWatch(_ result: PageResult) {
        lastResult = result
        isLoading = false
        notifyPaging()
    }
    
    func notifyFetch(_ result: FetchResult) {
        isLoading = false
        lastResult = result.result?.pageableEnvelope
        
        let errorEnvelope = PagingErrorEnvelope(
            queryErrors: result.result?.queryErrors,
            networkError: result.error)
        
        if errorEnvelope.hasErrors {
            lastError = errorEnvelope
        }
        notifyPaging()
    }
    
    func notifyPaging() {
        dataChangeCallback?()
    }
}
