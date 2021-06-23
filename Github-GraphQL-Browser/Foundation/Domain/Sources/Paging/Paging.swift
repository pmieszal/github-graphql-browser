import Foundation

/**
 This is a happy attempt to do really simple paging,
 It's build on PageWatchers that watches cache changes for each page.
 Right now it's done just for happy path.
 
 Has limited functionality when it comes to handling error - when error appears it's unable to request failed page again,
 it has to be refreshed. But it should not take much time to implement this case in my opinion.
 */
class Paging<TData: Hashable> {
    typealias WatcherFactory = (PageQueryInfo, (() -> ())?) -> PageWatcher<TData>
    
    private let pageItemsCount: Int
    private var watcherFactory: WatcherFactory?
    private var eventsCallback: ((PagingState<TData>) -> ())?
    private var watchers = [PageWatcher<TData>]()
    private var isRefreshing = false
    
    private var state: PagingState<TData> {
        let data = watchers.compactMap { $0.lastResult?.data }
        let isLoading = watchers.last?.isLoading == true
        let errors = watchers.last?.lastError
        
        return PagingState(data: data, isLoading: isLoading, errors: errors)
    }
    
    init(pageItemsCount: Int) {
        self.pageItemsCount = pageItemsCount
    }
    
    func start(eventsCallback: ((PagingState<TData>) -> ())?,
               watcherFactory: WatcherFactory?) {
        self.eventsCallback = eventsCallback
        self.watcherFactory = watcherFactory
    }
    
    func requestNextPage() {
        let lastLoadedWatcher = watchers.last(where: { $0.lastError == nil }) ?? watchers.first
        let lastLoadedPageInfo = lastLoadedWatcher?.lastResult?.pageInfo
        
        // Don't fetch next page if there is no next page
        if let hasNextPage = lastLoadedPageInfo?.hasNextPage,
           hasNextPage == false {
            return
        }
        
        /*
         SHORTCUT: Don't fetch next page if last watcher returned an error.
         */
        let lastWatcherError = watchers.last(where: { $0.lastError != nil })
        if lastWatcherError != nil {
            return
        }
        
        let pageQueryInfo = PageQueryInfo(pageItemsCount: pageItemsCount, lastPageInfo: lastLoadedPageInfo)
        
        guard let watcher = watcherFactory?(pageQueryInfo, { [weak self] in
            self?.notifyData()
        }) else {
            return
        }
        
        if let index = watchers.firstIndex(of: watcher) {
            let watcher = watchers[index]
            watcher.fetch()
            return
        }
        
        watcher.watch()
        watcher.fetch()
        
        watchers.append(watcher)
        notifyData()
    }
    
    /**
     In my opinion `refresh` method is not ready yet. Edge cases unit tests are needed.
     */
    func refresh() {
        unsubscribe()
        
        let pageQueryInfo = PageQueryInfo(pageItemsCount: pageItemsCount, lastPageInfo: nil)
        guard let firstPageWatcher = getNextPageWatcher(pageQueryInfo: pageQueryInfo) else {
            return
        }
        
        firstPageWatcher.fetch(firstPageWatcher.watch)
        
        watchers.append(firstPageWatcher)
    }
    
    /**
     Unsubscribe watchers to prevent memory leak https://www.apollographql.com/docs/ios/caching/#watching-queries
     
     NOTE: Remember to call cancel() on a watcher when its parent object is deallocated,
     or you will get a memory leak! This is not (presently) done automatically.
     */
    func unsubscribe() {
        watchers.forEach {
            $0.cancel()
        }
        watchers = []
    }
}

private extension Paging {
    func notifyData() {
        eventsCallback?(state)
    }
    
    func getNextPageWatcher(pageQueryInfo: PageQueryInfo) -> PageWatcher<TData>? {
        watcherFactory?(pageQueryInfo, { [weak self] in
            self?.notifyData()
        })
    }
}
