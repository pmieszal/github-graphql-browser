import Foundation
import Domain
import Core

enum RepositoryListItem: Hashable {
    case repository(RepositoryListCellPresentable)
    case error(ListErrorCellPresentable)
}
