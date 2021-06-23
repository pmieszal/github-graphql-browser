import RepositoryList

public class RepositoryListNavigationMock: RepositoryListNavigation {
    public typealias RepositoryListDidSelectRepositoryCallback = (owner: String, name: String)
    public var didSelectRepositoryCallback: ((RepositoryListDidSelectRepositoryCallback) -> ())?
    
    public init() {}
    
    public func repositoryListDidSelectRepository(owner: String, name: String) {
        didSelectRepositoryCallback?((owner, name))
    }
}
