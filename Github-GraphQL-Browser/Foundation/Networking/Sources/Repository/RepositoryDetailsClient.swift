import Domain

public class RepositoryDetailsClient: RepositoryDetailsService {
    let graphQLClient: GraphQLClientProtocol
    
    public init(graphQLClient: GraphQLClientProtocol) {
        self.graphQLClient = graphQLClient
    }
    
    public func fetchQuery(_ query: Domain.RepositoryDetailsQuery,
                           completion: ((QueryResult<QueryResultEnvelope<RepositoryDetails>>) -> ())?) -> CancellableObject {
        graphQLClient.fetch(
            query.toGraphQLQuery(),
            completion: { result in
                switch result {
                case let .success(response):
                    if let envelope = response.data?.toEnvelope(errors: response.graphQlErrors) {
                        completion?(.success(envelope))
                    } else {
                        let envelope = QueryResultEnvelope<RepositoryDetails>(data: nil, queryErrors: response.graphQlErrors)
                        completion?(.success(envelope))
                    }
                case let .failure(error):
                    completion?(.failure(error))
                }
            })
    }
}
