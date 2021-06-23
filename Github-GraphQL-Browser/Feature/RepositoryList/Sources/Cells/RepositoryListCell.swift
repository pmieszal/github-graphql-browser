import Domain
import UIKit

struct RepositoryListCellPresentable: Hashable {
    let id: String?, name: String?, url: String?
    
    init(repository: Repository) {
        id = repository.id
        name = repository.name
        url = repository.url
    }
}

class RepositoryListCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        textLabel?.font = .systemFont(ofSize: UIFont.labelFontSize, weight: .bold)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureWithPresentable(_ presentable: RepositoryListCellPresentable) {
        textLabel?.text = presentable.name
        detailTextLabel?.text = presentable.url
    }
}
