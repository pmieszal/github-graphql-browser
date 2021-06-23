import Apollo
import AppSecrets
import Domain
import Foundation
import Networking
import NetworkingMocks
import RepositoryDetails

public class RepositoryDetailsDependencyMock: RepositoryDetailsDependency {
    public init() {}
    
    public var itemsCount = 10
    public var url = AppSecrets.apiURL
    public var token = AppSecrets.apiToken
    public lazy var graphQLClient = GraphQLClientBuilder.build(url: URL(string: url)!, token: token)
    
    var repositoryDetailsService: RepositoryDetailsService {
        RepositoryDetailsClient(graphQLClient: graphQLClient)
    }

    public var repositoryDetailsFetchUseCase: RepositoryDetailsFetchUseCase {
        RepositoryDetailsFetchUseCase(service: repositoryDetailsService, itemsCount: itemsCount)
    }
}

// swiftlint:disable force_try
public func uiTestsMock() -> RepositoryDetailsDependencyMock {
    var bundle: Bundle {
        NetworkingMocksResources.bundle
    }
    
    var repositoryDetailsResponseMock: Data {
        let url = bundle.url(forResource: "repository-details-response-mock", withExtension: "json")!
        return try! Data(contentsOf: url)
    }
    
    let clientMock = URLSessionClientMock()
    let data = repositoryDetailsResponseMock
    let response = HTTPURLResponse()
    let result = (data, response)
    clientMock.appendResult(.success(result))
    
    let dependency = RepositoryDetailsDependencyMock()
    
    dependency.graphQLClient = GraphQLClientMockBuilder.build(sessionClientMock: clientMock)
    dependency.url = "https://localhost:1234"
    dependency.token = "token"
    dependency.itemsCount = 10
    
    return dependency
}
