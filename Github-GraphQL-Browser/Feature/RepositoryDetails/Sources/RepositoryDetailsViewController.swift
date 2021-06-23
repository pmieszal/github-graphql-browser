import Core
import UIKit

protocol RepositoryDetailsViewControllerLogic: AnyObject {
    func displayName(_ name: String)
    func applySnapshot(_ snapshot: NSDiffableDataSourceSnapshot<RepositoryDetailsSection, RepositoryDetailsItem>)
}

final class RepositoryDetailsViewController: UIViewController {
    lazy var tableView = UITableView()
    lazy var dataSource = RepositoryDetailsDataSource(tableView: tableView)
    
    var interactor: RepositoryDetailsInteractorLogic?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        interactor?.viewDidLoad()
    }
}

extension RepositoryDetailsViewController: RepositoryDetailsViewControllerLogic {
    func displayName(_ name: String) {
        navigationItem.title = name
    }
    
    func applySnapshot(_ snapshot: NSDiffableDataSourceSnapshot<RepositoryDetailsSection, RepositoryDetailsItem>) {
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

private extension RepositoryDetailsViewController {
    func setup() {
        view.backgroundColor = .systemBackground
        dataSource.defaultRowAnimation = .fade

        tableView.register(RepositoryDetailsListCell.self)
        tableView.register(ListErrorCell.self)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
