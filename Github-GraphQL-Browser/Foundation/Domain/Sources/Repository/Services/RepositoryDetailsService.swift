import Foundation

public protocol RepositoryDetailsService {
    func fetchQuery(_ query: RepositoryDetailsQuery,
                    completion: ((QueryResult<QueryResultEnvelope<RepositoryDetails>>) -> ())?) -> CancellableObject
}
