import Foundation

public struct RepositoriesQuery: Hashable {
    public let owner: String, count: Int, after: String?
}
