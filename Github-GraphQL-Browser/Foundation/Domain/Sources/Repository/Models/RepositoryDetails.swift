public struct RepositoryDetails {
    public let id: String?
    public let name: String?
    public let openedIssues: RepositoryDetailsItemWrapper<RepositoryIssue>
    public let closedIssues: RepositoryDetailsItemWrapper<RepositoryIssue>
    public let openedPRs: RepositoryDetailsItemWrapper<RepositoryPullRequest>
    public let closedPRs: RepositoryDetailsItemWrapper<RepositoryPullRequest>
    
    public init(id: String?,
                name: String?,
                openedIssues: RepositoryDetailsItemWrapper<RepositoryIssue>,
                closedIssues: RepositoryDetailsItemWrapper<RepositoryIssue>,
                openedPRs: RepositoryDetailsItemWrapper<RepositoryPullRequest>,
                closedPRs: RepositoryDetailsItemWrapper<RepositoryPullRequest>) {
        self.id = id
        self.name = name
        self.openedIssues = openedIssues
        self.closedIssues = closedIssues
        self.openedPRs = openedPRs
        self.closedPRs = closedPRs
    }
}

public struct RepositoryDetailsItemWrapper<TItem: Hashable> {
    public let items: [TItem]
    public let totalCount: Int
    
    public init(items: [TItem], totalCount: Int) {
        self.items = items
        self.totalCount = totalCount
    }
}
