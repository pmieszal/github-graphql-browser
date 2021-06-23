import Foundation

enum RepositoryDetailsSectionType: Hashable {
    case openedIssues
    case closedIssues
    case openedPRs
    case closedPRs
    
    var name: String {
        switch self {
        case .openedIssues:
            return RepositoryDetailsStrings.repositoryDetailsSectionOpenedIssuesTitle
        case .closedIssues:
            return RepositoryDetailsStrings.repositoryDetailsSectionClosedIssuesTitle
        case .openedPRs:
            return RepositoryDetailsStrings.repositoryDetailsSectionOpenedPullRequestsTitle
        case .closedPRs:
            return RepositoryDetailsStrings.repositoryDetailsSectionClosedPullRequestsTitle
        }
    }
}
