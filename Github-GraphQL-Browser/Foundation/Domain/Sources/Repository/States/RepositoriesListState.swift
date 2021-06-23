import Foundation

public struct RepositoriesListState {
    public let list: [Repository]
    public let error: LocalizedError?
    public let isLoading: Bool
}
