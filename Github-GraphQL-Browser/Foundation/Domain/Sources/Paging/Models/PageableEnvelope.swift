import Foundation

public struct PageableEnvelope<TData: Hashable>: Hashable {
    let data: TData
    let pageInfo: PageInfo?
    
    public init(data: TData,
                pageInfo: PageInfo?) {
        self.data = data
        self.pageInfo = pageInfo
    }
}
