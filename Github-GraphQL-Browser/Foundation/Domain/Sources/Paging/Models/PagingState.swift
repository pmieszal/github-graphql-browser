import Foundation

struct PagingState<TPage> {
    let data: [TPage]?
    let isLoading: Bool
    let errors: PagingErrorEnvelope?
}
