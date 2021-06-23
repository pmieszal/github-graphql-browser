public protocol RepositoriesService {
    func watchChangesForQuery(_ query: RepositoriesQuery,
                              handler: ((PageableEnvelope<[Repository]>) -> ())?) -> CancellableObject
    func refreshQuery(_ query: RepositoriesQuery,
                      completion: ((QueryResult<QueryPageableResultEnvelope<[Repository]>>) -> ())?) -> CancellableObject
}
