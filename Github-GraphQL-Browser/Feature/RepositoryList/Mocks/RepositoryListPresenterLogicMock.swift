@testable import RepositoryList

public class RepositoryListPresenterLogicMock: RepositoryListPresenterLogic {
    public var presentOwnerCallback: ((String) -> ())?
    public var presentListCallback: ((RepositoriesListPresentable) -> ())?
    
    public init() {}
    
    public func presentOwner(_ owner: String) {
        presentOwnerCallback?(owner)
    }
    
    public func presentList(_ presentable: RepositoriesListPresentable) {
        presentListCallback?(presentable)
    }
}
