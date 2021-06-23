import Apollo
import Foundation

public enum GraphQLClientBuilder {
    public static func build(url: URL,
                             token: String,
                             cache: NormalizedCache = InMemoryNormalizedCache()) -> GraphQLClientProtocol {
        let store = ApolloStore(cache: cache)
        store.cacheKeyForObject = {
            $0["id"]
        }
              
        let client = URLSessionClient()
        let provider = NetworkInterceptorProvider(store: store, client: client, token: token)

        let requestChainTransport = RequestChainNetworkTransport(
            interceptorProvider: provider,
            endpointURL: url)
                                                                       
        let apolloClient = ApolloClient(
            networkTransport: requestChainTransport,
            store: store)
        
        let graphQLClient = GraphQLClient(
            apolloClient: apolloClient,
            callbackQueue: DispatchQueue.global(qos: DispatchQoS.QoSClass.background))
        let workaround = GraphQLClientWatcherWorkaround(graphQLClient: graphQLClient)
        
        return workaround
    }
}
