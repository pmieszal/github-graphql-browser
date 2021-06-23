import Apollo
import Foundation
import Networking

public enum GraphQLClientMockBuilder {
    public static func build(
        sessionClientMock: URLSessionClientMock,
        apolloStore: ApolloStore? = nil
    ) -> GraphQLClient {
        let store = apolloStore ?? ApolloStore(cache: InMemoryNormalizedCache())
        store.cacheKeyForObject = {
            $0["id"]
        }
        
        let provider = LegacyInterceptorProvider(
            client: sessionClientMock,
            store: store)
        let transport = RequestChainNetworkTransport(
            interceptorProvider: provider,
            endpointURL: URL(string: "https://localhost:1234")!)
        let apolloClient = ApolloClient(
            networkTransport: transport,
            store: store)
        let graphQLClient = GraphQLClient(
            apolloClient: apolloClient,
            callbackQueue: DispatchQueue.global(qos: DispatchQoS.QoSClass.background))
        
        return graphQLClient
    }
}
