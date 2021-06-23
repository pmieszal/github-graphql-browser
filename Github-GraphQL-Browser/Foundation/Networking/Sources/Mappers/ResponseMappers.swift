import Domain
import Foundation

/**
 This whole file is "shortcut", ideally extensions should be in classes/separate files.
 */

extension RepositoryListQuery.Data {
    func toEnvelope(errors: [LocalizedError]?) -> PageableEnvelope<[Repository]> {
        let repositories = repositoryOwner?.repositories.nodes?.map {
            Repository(id: $0?.id, name: $0?.name, url: $0?.url)
        } ?? []
        
        let resultPageInfo = repositoryOwner?.repositories.pageInfo
        let pageInfo = resultPageInfo.map {
            PageInfo(hasNextPage: $0.hasNextPage, endCursor: $0.endCursor)
        }
        
        let envelope = PageableEnvelope(data: repositories, pageInfo: pageInfo)
        
        return envelope
    }
}

extension RepositoryDetailsQuery.Data {
    func toEnvelope(errors: [LocalizedError]?) -> QueryResultEnvelope<RepositoryDetails> {
        let openedIssuesWrapper = RepositoryDetailsItemWrapper(issue: repository?.openedIssues)
        let closedIssuesWrapper = RepositoryDetailsItemWrapper(issue: repository?.closedIssues)
        let openedPRsWrapper = RepositoryDetailsItemWrapper(pullRequest: repository?.openedPRs)
        let closedPRsWrapper = RepositoryDetailsItemWrapper(pullRequest: repository?.closedPRs)
        
        let details = RepositoryDetails(
            id: repository?.id,
            name: repository?.name,
            openedIssues: openedIssuesWrapper,
            closedIssues: closedIssuesWrapper,
            openedPRs: openedPRsWrapper,
            closedPRs: closedPRsWrapper)
        let envelope = QueryResultEnvelope(data: details, queryErrors: errors)
        
        return envelope
    }
}

extension RepositoryDetailsItemWrapper where TItem == RepositoryIssue {
    init(issue: RepositoryDetailsQuery.Data.Repository.OpenedIssue?) {
        let items = issue?.nodes?.compactMap(RepositoryIssue.init)
        self.init(items: items ?? [], totalCount: issue?.totalCount ?? 0)
    }
    
    init(issue: RepositoryDetailsQuery.Data.Repository.ClosedIssue?) {
        let items = issue?.nodes?.compactMap(RepositoryIssue.init)
        self.init(items: items ?? [], totalCount: issue?.totalCount ?? 0)
    }
}

extension RepositoryDetailsItemWrapper where TItem == RepositoryPullRequest {
    init(pullRequest: RepositoryDetailsQuery.Data.Repository.OpenedPr?) {
        let items = pullRequest?.nodes?.compactMap(RepositoryPullRequest.init)
        self.init(items: items ?? [], totalCount: pullRequest?.totalCount ?? 0)
    }
    
    init(pullRequest: RepositoryDetailsQuery.Data.Repository.ClosedPr?) {
        let items = pullRequest?.nodes?.compactMap(RepositoryPullRequest.init)
        self.init(items: items ?? [], totalCount: pullRequest?.totalCount ?? 0)
    }
}

extension RepositoryIssue {
    init?(node: RepositoryDetailsQuery.Data.Repository.OpenedIssue.Node?) {
        guard let node = node else {
            return nil
        }
        self.init(
            id: node.id,
            number: node.number,
            title: node.title,
            url: node.url,
            closed: node.closed)
    }

    init?(node: RepositoryDetailsQuery.Data.Repository.ClosedIssue.Node?) {
        guard let node = node else {
            return nil
        }
        self.init(
            id: node.id,
            number: node.number,
            title: node.title,
            url: node.url,
            closed: node.closed)
    }
}

extension RepositoryPullRequest {
    init?(node: RepositoryDetailsQuery.Data.Repository.OpenedPr.Node?) {
        guard let node = node else {
            return nil
        }
        self.init(
            id: node.id,
            number: node.number,
            title: node.title,
            url: node.url,
            closed: node.closed)
    }

    init?(node: RepositoryDetailsQuery.Data.Repository.ClosedPr.Node?) {
        guard let node = node else {
            return nil
        }
        self.init(
            id: node.id,
            number: node.number,
            title: node.title,
            url: node.url,
            closed: node.closed)
    }
}
