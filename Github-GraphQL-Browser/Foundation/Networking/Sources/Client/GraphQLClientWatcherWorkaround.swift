import Apollo
import Domain

/**
 Most likely there is a bug in Apollo that unsubscribes from cache watching when
 is firstly invoked with empty cache, so my workaround is storing all watcher handlers
 and recreates watcher when `refresh` method succeeds.

 Issue: https://github.com/apollographql/apollo-ios/issues/99
 Should be fixed in [Mega-Issue] Cache Improvements: https://github.com/apollographql/apollo-ios/issues/1701
  */
public class GraphQLClientWatcherWorkaround: GraphQLClientProtocol {
    typealias QueryWatcher = ((Any?) -> (), AnyReplaceableCancellableObject)
    private var watchersDict = [AnyHashable: [QueryWatcher]]()
    
    let graphQLClient: GraphQLClientProtocol
    
    public init(graphQLClient: GraphQLClientProtocol) {
        self.graphQLClient = graphQLClient
    }
    
    @discardableResult
    public func watch<TQuery: GraphQLQuery>(_ query: TQuery,
                                            handler: ((TQuery.Data?) -> ())?) -> CancellableObject {
        watch(query, applyWorkaround: true, handler: handler)
    }
    
    @discardableResult
    public func fetchIgnoringCacheData<TQuery: GraphQLQuery>(
        _ query: TQuery,
        completion: ((Result<GraphQLQueryResponse<TQuery>, NetworkingError>) -> ())?
    ) -> CancellableObject {
        graphQLClient.fetchIgnoringCacheData(query, completion: { [weak self] result in
            completion?(result)
            self?.rewatchQuery(query)
        })
    }
    
    @discardableResult
    public func fetch<TQuery: GraphQLQuery>(
        _ query: TQuery,
        completion: ((Result<GraphQLQueryResponse<TQuery>, NetworkingError>) -> ())?
    ) -> CancellableObject {
        graphQLClient.fetch(query, completion: { [weak self] result in
            completion?(result)
            self?.rewatchQuery(query)
        })
    }
}
    
private extension GraphQLClientWatcherWorkaround {
    @discardableResult
    func watch<TQuery: GraphQLQuery>(_ query: TQuery,
                                     applyWorkaround: Bool,
                                     handler: ((TQuery.Data?) -> ())?) -> CancellableObject {
        let cancellable = graphQLClient.watch(query, handler: handler)
        let replaceableCancellable = AnyReplaceableCancellableObject(cancel: cancellable.cancel)
        
        if applyWorkaround {
            let queryWatcher = QueryWatcher({ handler?($0 as? TQuery.Data) }, replaceableCancellable)
            appendWatcherForQuery(query, watcher: queryWatcher)
        }

        return replaceableCancellable
    }

    func appendWatcherForQuery<TQuery: GraphQLQuery>(_ query: TQuery,
                                                     watcher: QueryWatcher) {
        let key = query.watcherKey
        var handlers = watchersDict[key] ?? []
        handlers.append(watcher)
        
        watchersDict[key] = handlers
    }
    
    func rewatchQuery<TQuery: GraphQLQuery>(_ query: TQuery) {
        let key = query.watcherKey
        guard let watchers = watchersDict[key] else {
            return
        }
        
        for watcher in watchers {
            watcher.1.cancel()
            let cancelable = watch(query, applyWorkaround: false, handler: watcher.0)
            watcher.1.replaceCancel(cancelable.cancel)
        }
    }
}
