import Foundation
@testable import RepositoryDetails

public class RepositoryDetailsPresenterLogicMock: RepositoryDetailsPresenterLogic {
    public var presentNameCallback: ((String) -> ())?
    public var presentDetailsCallback: ((RepositoryDetailsPresentable) -> ())?
    
    public init() {}
    
    public func presentName(_ name: String) {
        presentNameCallback?(name)
    }
    
    public func presentDetails(_ details: RepositoryDetailsPresentable) {
        presentDetailsCallback?(details)
    }
}
