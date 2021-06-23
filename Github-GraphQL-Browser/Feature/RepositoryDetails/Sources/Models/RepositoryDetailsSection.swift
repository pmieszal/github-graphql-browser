import Foundation

struct RepositoryDetailsSection: Hashable {
    let type: RepositoryDetailsSectionType
    let totalCount: Int
    
    var title: String {
        type.name.appending(" (\(totalCount))")
    }
}
