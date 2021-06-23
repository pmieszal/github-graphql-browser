import ChooseOwner
import Foundation

public class ChooseOwnerNavigationMock: ChooseOwnerNavigation {
    public var chooseOwnerDidSelectOwnerCallback: ((String) -> ())?
    public init() {}
    
    public func chooseOwnerDidSelectOwner(_ owner: String) {
        chooseOwnerDidSelectOwnerCallback?(owner)
    }
}
