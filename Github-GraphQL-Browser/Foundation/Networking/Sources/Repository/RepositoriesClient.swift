import Domain

public class RepositoriesClient: RepositoriesService {
    let graphQLClient: GraphQLClientProtocol
    
    public init(graphQLClient: GraphQLClientProtocol) {
        self.graphQLClient = graphQLClient
    }
    
    public func watchChangesForQuery(_ query: RepositoriesQuery,
                                     handler: ((PageableEnvelope<[Repository]>) -> ())?) -> CancellableObject {
        graphQLClient
            .watch(
                query.toGraphQLQuery(),
                handler: { result in
                    guard let envelope = result?.toEnvelope(errors: nil) else {
                        return
                    }
                    handler?(envelope)
                })
    }
    
    public func refreshQuery(
        _ query: RepositoriesQuery,
        completion: ((QueryResult<QueryPageableResultEnvelope<[Repository]>>) -> ())?
    ) -> CancellableObject {
        graphQLClient
            .fetchIgnoringCacheData(query.toGraphQLQuery()) { result in
                switch result {
                case let .success(result):
                    if let envelope = result.data?.toEnvelope(errors: result.graphQlErrors) {
                        let result = QueryPageableResultEnvelope(
                            pageableEnvelope: envelope,
                            queryErrors: result.graphQlErrors)
                        completion?(.success(result))
                    } else {
                        let result = QueryPageableResultEnvelope<[Repository]>(
                            pageableEnvelope: PageableEnvelope(data: [], pageInfo: nil),
                            queryErrors: result.graphQlErrors)
                        
                        completion?(.success(result))
                    }
                case let .failure(error):
                    completion?(.failure(error))
                }
            }
    }
}
