import Apollo
import AppSecrets
import Domain
import Foundation
import Networking
import NetworkingMocks
import RepositoryList

public class RepositoryListDependenciesMock: RepositoryListDependency {
    public init() {}
    
    public var pageItemsCount = 20
    public var url = AppSecrets.apiURL
    public var token = AppSecrets.apiToken
    public lazy var graphQLClient = GraphQLClientBuilder.build(url: URL(string: url)!, token: token)
    
    var repositoryService: RepositoriesService {
        RepositoriesClient(graphQLClient: graphQLClient)
    }
    
    public var repositoriesWatchUseCase: RepositoriesWatchUseCase {
        RepositoriesWatchUseCase(service: repositoryService, pageItemsCount: pageItemsCount)
    }
}

// swiftlint:disable force_try
public func uiTestsMock() -> RepositoryListDependenciesMock {
    var bundle: Bundle {
        NetworkingMocksResources.bundle
    }
    
    var repositoryListResponseMock: Data {
        let url = bundle.url(forResource: "repository-list-response-mock", withExtension: "json")!
        return try! Data(contentsOf: url)
    }
    
    let clientMock = URLSessionClientMock()
    let data = repositoryListResponseMock
    let response = HTTPURLResponse()
    let result = (data, response)
    clientMock.appendResult(.success(result))
    
    let dependency = RepositoryListDependenciesMock()
    
    dependency.graphQLClient = GraphQLClientMockBuilder.build(sessionClientMock: clientMock)
    dependency.url = "https://localhost:1234"
    dependency.token = "token"
    dependency.pageItemsCount = 20
    
    return dependency
}
