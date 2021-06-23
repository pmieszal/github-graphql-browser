import Core
import Domain
import UIKit

protocol RepositoryListInteractorLogic: RepositoryListDataStore {
    func viewDidLoad()
    func loadNextPage()
}

protocol RepositoryListDataStore {
    var owner: String { get }
}

final class RepositoryListInteractor: RepositoryListDataStore {
    let presenter: RepositoryListPresenterLogic
    let repositoriesWatchUseCase: RepositoriesWatchUseCase
    let owner: String

    init(presenter: RepositoryListPresenterLogic,
         owner: String,
         dependency: RepositoryListDependency) {
        self.presenter = presenter
        self.owner = owner
        repositoriesWatchUseCase = dependency.repositoriesWatchUseCase
    }
    
    deinit {
        repositoriesWatchUseCase.unsubscribe()
    }
}

extension RepositoryListInteractor: RepositoryListInteractorLogic {
    func viewDidLoad() {
        presenter.presentOwner(owner)
        repositoriesWatchUseCase.watchRepositoriesForOwner(
            owner: owner,
            stateEventsHandler: { [weak self] state in
                self?.stateEventsHandler(state)
            })
        repositoriesWatchUseCase.loadNextPage()
    }
    
    func loadNextPage() {
        repositoriesWatchUseCase.loadNextPage()
    }
}

private extension RepositoryListInteractor {
    func stateEventsHandler(_ state: RepositoriesListState) {
        let presentable = RepositoriesListPresentable(state: state)
        presenter.presentList(presentable)
    }
}
