import UIKit

@objc protocol RepositoryDetailsRouterProtocol {}

final class RepositoryDetailsRouter {
    let dataStore: RepositoryDetailsDataStore
    weak var viewController: RepositoryDetailsViewController?

    init(viewController: RepositoryDetailsViewController?,
         dataStore: RepositoryDetailsDataStore) {
        self.viewController = viewController
        self.dataStore = dataStore
    }
}

extension RepositoryDetailsRouter: RepositoryDetailsRouterProtocol {}
