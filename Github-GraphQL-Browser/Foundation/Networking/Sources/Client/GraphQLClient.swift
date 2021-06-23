import Apollo
import Domain
import Foundation

public final class GraphQLClient: GraphQLClientProtocol {
    let apolloClient: ApolloClient
    let callbackQueue: DispatchQueue
    
    public init(apolloClient: ApolloClient,
                callbackQueue: DispatchQueue) {
        self.apolloClient = apolloClient
        self.callbackQueue = callbackQueue
    }
    
    /**
     Method that watches every cache changes for given query.
     */
    @discardableResult
    public func watch<TQuery: GraphQLQuery>(
        _ query: TQuery,
        handler: ((TQuery.Data?) -> ())?
    ) -> CancellableObject {
        apolloClient.watch(
            query: query,
            cachePolicy: .returnCacheDataDontFetch,
            callbackQueue: callbackQueue,
            resultHandler: { result in
                switch result {
                case let .success(result):
                    handler?(result.data)
                case let .failure(error):
                    // This is watch only, errors are handled in refresh method
                    // SHORTCUT: NSLog instead of real logger
                    NSLog("Error when watching for query: %@, error: %@", query.operationName, error.localizedDescription)
                    handler?(nil)
                }
            }
        )
        .toAnyCancellableObject()
    }
    
    /**
     Method that refreshes given query. Subscribe with `watch` method to receive cache changes.
     Completes with GraphQLQueryResponse.
     */
    @discardableResult
    public func fetchIgnoringCacheData<TQuery: GraphQLQuery>(
        _ query: TQuery,
        completion: ((Result<GraphQLQueryResponse<TQuery>, NetworkingError>) -> ())?
    ) -> CancellableObject {
        fetch(query, cachePolicy: .fetchIgnoringCacheData, completion: completion)
    }
    
    @discardableResult
    public func fetch<TQuery: GraphQLQuery>(
        _ query: TQuery,
        completion: ((Result<GraphQLQueryResponse<TQuery>, NetworkingError>) -> ())?
    ) -> CancellableObject {
        fetch(query, cachePolicy: .returnCacheDataAndFetch, completion: completion)
    }
}

extension GraphQLClient {
    @discardableResult
    func fetch<TQuery: GraphQLQuery>(
        _ query: TQuery,
        cachePolicy: CachePolicy,
        completion: ((Result<GraphQLQueryResponse<TQuery>, NetworkingError>) -> ())?
    ) -> CancellableObject {
        apolloClient.fetch(
            query: query,
            cachePolicy: cachePolicy,
            queue: callbackQueue,
            resultHandler: { result in
                switch result {
                case let .success(result):
                    let response = GraphQLQueryResponse<TQuery>(data: result.data, graphQlErrors: result.errors)
                    completion?(.success(response))
                case let .failure(error):
                    completion?(.failure(NetworkingError(error: error)))
                }
            }
        )
        .toAnyCancellableObject()
    }
}
