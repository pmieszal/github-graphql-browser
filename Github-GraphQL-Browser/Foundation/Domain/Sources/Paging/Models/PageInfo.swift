import Foundation

public struct PageInfo: Hashable {
    let hasNextPage: Bool
    let endCursor: String?
    
    public init(hasNextPage: Bool, endCursor: String? = nil) {
        self.hasNextPage = hasNextPage
        self.endCursor = endCursor
    }
}
