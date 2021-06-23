import Core
import UIKit

class RepositoryDetailsDataSource: UITableViewDiffableDataSource<RepositoryDetailsSection, RepositoryDetailsItem> {
    init(tableView: UITableView) {
        super.init(
            tableView: tableView,
            cellProvider: { tableView, indexPath, item in
                switch item {
                case let .issue(presentable),
                     let .pullRequest(presentable):
                    let cell = tableView.dequeueReusableCell(type: RepositoryDetailsListCell.self, for: indexPath)
                    cell?.configureWithPresentable(presentable)
                    
                    return cell
                case let .error(presentable):
                    let cell = tableView.dequeueReusableCell(type: ListErrorCell.self, for: indexPath)
                    cell?.configureWithPresentable(presentable)
                    
                    return cell
                }
            })
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        snapshot().sectionIdentifiers[section].title
    }
}
