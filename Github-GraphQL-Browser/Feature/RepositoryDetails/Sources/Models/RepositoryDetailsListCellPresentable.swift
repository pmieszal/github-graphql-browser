import Domain
import Foundation

struct RepositoryDetailsListCellPresentable: Hashable {
    let id: String
    let title: String?
    
    init(issue: RepositoryIssue) {
        id = issue.id
        title = issue.title
    }
    
    init(pullRequest: RepositoryPullRequest) {
        id = pullRequest.id
        title = pullRequest.title
    }
}
