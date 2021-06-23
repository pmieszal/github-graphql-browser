import Domain
import UIKit

protocol RepositoryDetailsInteractorLogic {
    func viewDidLoad()
}

protocol RepositoryDetailsDataStore {}

final class RepositoryDetailsInteractor: RepositoryDetailsDataStore {
    let presenter: RepositoryDetailsPresenterLogic
    let repositoryDetailsFetchUseCase: RepositoryDetailsFetchUseCase
    let owner: String
    let name: String

    init(presenter: RepositoryDetailsPresenterLogic,
         dependency: RepositoryDetailsDependency,
         owner: String,
         name: String) {
        self.presenter = presenter
        self.owner = owner
        self.name = name
        repositoryDetailsFetchUseCase = dependency.repositoryDetailsFetchUseCase
    }
}

extension RepositoryDetailsInteractor: RepositoryDetailsInteractorLogic {
    func viewDidLoad() {
        repositoryDetailsFetchUseCase.fetchDetails(
            owner: owner,
            name: name,
            handler: handleFetchState)
        
        presenter.presentName(name)
    }
}

private extension RepositoryDetailsInteractor {
    func handleFetchState(_ state: RepositoryDetailsState) {
        let presentable = RepositoryDetailsPresentable(state: state)
        presenter.presentDetails(presentable)
    }
}
