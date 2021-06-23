import Domain

extension Domain.RepositoriesQuery {
    func toGraphQLQuery() -> RepositoryListQuery {
        RepositoryListQuery(owner: owner, count: count, after: after)
    }
}

extension Domain.RepositoryDetailsQuery {
    func toGraphQLQuery() -> RepositoryDetailsQuery {
        RepositoryDetailsQuery(
            owner: owner,
            name: name,
            issuesCount: issuesCount,
            pullRequestsCount: pullRequestsCount)
    }
}
