import Apollo
import Foundation

public struct NetworkInterceptorProvider: InterceptorProvider {
    private let store: ApolloStore
    private let client: URLSessionClient
    private let token: String
    
    public init(store: ApolloStore,
                client: URLSessionClient,
                token: String) {
        self.store = store
        self.client = client
        self.token = token
    }
    
    public func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
        return [
            MaxRetryInterceptor(),
            LegacyCacheReadInterceptor(store: store),
            AuthorizationInterceptor(token: token),
            NetworkFetchInterceptor(client: client),
            ResponseCodeInterceptor(),
            LegacyParsingInterceptor(cacheKeyForObject: store.cacheKeyForObject),
            AutomaticPersistedQueryInterceptor(),
            LegacyCacheWriteInterceptor(store: store),
        ]
    }
}
