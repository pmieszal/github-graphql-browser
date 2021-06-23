import Domain
import Core

enum RepositoryDetailsItem: Hashable {
    case issue(RepositoryDetailsListCellPresentable)
    case pullRequest(RepositoryDetailsListCellPresentable)
    case error(ListErrorCellPresentable)
}
