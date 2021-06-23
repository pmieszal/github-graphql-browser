import Apollo
import Domain

extension Cancellable {
    func toAnyCancellableObject() -> CancellableObject {
        AnyCancellableObject(cancel: cancel)
    }
}
