import ApolloSQLite
import AppSecrets
import ChooseOwner
import Domain
import Networking
import RepositoryDetails
import RepositoryList
import UIKit

class Dependencies {
    /*
     Singleton GraphQLClient client as recommended in documentation:
     https://www.apollographql.com/docs/ios/tutorial/tutorial-execute-query/#running-a-test-query
     
     It's recommended that this instance is a singleton or static instance that's accessible from anywhere in your codebase
     */
    lazy var graphQLClient: GraphQLClientProtocol = {
        // Doing some force unwrapping and force casting without which the world don't make any sense :)
        let documentsPath = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true).first!
        let documentsURL = URL(fileURLWithPath: documentsPath)
        let sqliteFileURL = documentsURL.appendingPathComponent("apollo_db.sqlite")
        
        // swiftlint:disable:next force_try
        let cache = try! SQLiteNormalizedCache(fileURL: sqliteFileURL)
        
        return GraphQLClientBuilder.build(
            url: URL(string: AppSecrets.apiURL)!,
            token: AppSecrets.apiToken,
            cache: cache)
    }()
    
    var repositoryService: RepositoriesService {
        RepositoriesClient(graphQLClient: graphQLClient)
    }
    
    var repositoryDetailsService: RepositoryDetailsService {
        RepositoryDetailsClient(graphQLClient: graphQLClient)
    }
}

extension Dependencies: AppRouterDependency {
    func buildChooseOwner() -> UIViewController {
        let router = ChooseOwnerRouter(dependency: self)
        let chooseOwner = ChooseOwnerBuilder().buildChooseOwnerModule(dependency: self, navigation: router)
        router.setViewController(chooseOwner)
        
        return chooseOwner
    }
}

extension Dependencies: ChooseOwnerDependency {}

extension Dependencies: ChooseOwnerRouterDependency {
    func buildRepositoryList(owner: String) -> UIViewController {
        let router = RepositoryListRouter(dependency: self)
        let list = RepositoryListBuilder().buildRepositoryListModule(
            owner: owner,
            dependencies: self,
            navigation: router)
        router.setViewController(list)
        
        return list
    }
}

extension Dependencies: RepositoryListRouterDependency {
    func buildRepositoryDetails(owner: String, name: String) -> UIViewController {
        RepositoryDetailsBuilder().buildRepositoryDetailsModule(dependency: self, owner: owner, name: name)
    }
}

extension Dependencies: RepositoryListDependency {
    var repositoriesWatchUseCase: RepositoriesWatchUseCase {
        RepositoriesWatchUseCase(service: repositoryService, pageItemsCount: 20)
    }
}

extension Dependencies: RepositoryDetailsDependency {
    var repositoryDetailsFetchUseCase: RepositoryDetailsFetchUseCase {
        // SHORTCUT: display only first 10 items for details
        RepositoryDetailsFetchUseCase(service: repositoryDetailsService, itemsCount: 10)
    }
}
