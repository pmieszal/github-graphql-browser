import Core
import Domain
import UIKit

protocol RepositoryListViewControllerLogic: AnyObject {
    func displayOwner(_ owner: String)
    func displayLoading(_ isLoading: Bool)
    func applySnapshot(_ snapshot: NSDiffableDataSourceSnapshot<String, RepositoryListItem>)
}

final class RepositoryListViewController: UIViewController {
    private enum Consts {
        static let footerHeight = CGFloat(50)
        static let itemsToDisplayPagingTrigger = 10
    }
    
    lazy var footerActivityIndicator = UIActivityIndicatorView(style: .medium)
    lazy var tableView = UITableView()
    lazy var dataSource = UITableViewDiffableDataSource<String, RepositoryListItem>(
        tableView: tableView,
        cellProvider: { tableView, indexPath, item in
            switch item {
            case let .repository(presentable):
                let cell = tableView.dequeueReusableCell(type: RepositoryListCell.self, for: indexPath)
                cell?.configureWithPresentable(presentable)
                
                return cell
            case let .error(presentable):
                let cell = tableView.dequeueReusableCell(type: ListErrorCell.self, for: indexPath)
                cell?.configureWithPresentable(presentable)
                
                return cell
            }
        })
    
    var interactor: RepositoryListInteractorLogic?
    var navigation: RepositoryListNavigation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        interactor?.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.tableFooterView?.frame.size.height = Consts.footerHeight
    }
}

extension RepositoryListViewController: RepositoryListViewControllerLogic {
    func displayOwner(_ owner: String) {
        navigationItem.title = owner
    }
    
    func displayLoading(_ isLoading: Bool) {
        isLoading ? footerActivityIndicator.startAnimating() : footerActivityIndicator.stopAnimating()
    }
    
    func applySnapshot(_ snapshot: NSDiffableDataSourceSnapshot<String, RepositoryListItem>) {
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension RepositoryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let items = dataSource.tableView(tableView, numberOfRowsInSection: indexPath.section)
        let itemsToDisplay = items - indexPath.row
        
        if itemsToDisplay == Consts.itemsToDisplayPagingTrigger {
            interactor?.loadNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath),
              case let .repository(repository) = item,
              let name = repository.name,
              let owner = interactor?.owner else {
            return
        }
        
        navigation?.repositoryListDidSelectRepository(owner: owner, name: name)
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
    }
}

private extension RepositoryListViewController {
    func setup() {
        view.backgroundColor = .systemBackground
        
        footerActivityIndicator.hidesWhenStopped = true
        dataSource.defaultRowAnimation = .fade
        
        tableView.tableFooterView = footerActivityIndicator
        tableView.delegate = self
        tableView.register(RepositoryListCell.self)
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
