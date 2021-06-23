import Foundation
import Networking
import NetworkingMocks

// swiftlint:disable force_try
class UITestsMockDependencies: Dependencies {
    var bundle: Bundle {
        NetworkingMocksResources.bundle
    }
    
    var repositoryListResponseMock: Data {
        let url = bundle.url(forResource: "repository-list-response-one-page-mock", withExtension: "json")!
        return try! Data(contentsOf: url)
    }
    
    var repositoryDetailsResponseMock: Data {
        let url = bundle.url(forResource: "repository-details-response-mock", withExtension: "json")!
        return try! Data(contentsOf: url)
    }
    
    lazy var clientMock: URLSessionClientMock = {
        let clientMock = URLSessionClientMock()
        clientMock.appendResult(.success((repositoryListResponseMock, HTTPURLResponse())))
        clientMock.appendResult(.success((repositoryDetailsResponseMock, HTTPURLResponse())))
        
        return clientMock
    }()
    
    override init() {
        super.init()
        graphQLClient = GraphQLClientMockBuilder.build(sessionClientMock: clientMock)
    }
}
