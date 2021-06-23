import UIKit

public protocol IdentifiableCell {
    static var identifier: String { get }
}

extension UITableViewCell: IdentifiableCell {
    public static var identifier: String {
        String(describing: self)
    }
}

public extension UITableView {
    func register<TCell: UITableViewCell>(_ cellClass: TCell.Type) {
        register(cellClass, forCellReuseIdentifier: cellClass.identifier)
    }
    
    func dequeueReusableCell<TCell: UITableViewCell>(type: TCell.Type, for indexPath: IndexPath) -> TCell? {
        dequeueReusableCell(withIdentifier: type.identifier, for: indexPath) as? TCell
    }
}

extension UICollectionViewCell: IdentifiableCell {
    public static var identifier: String {
        String(describing: self)
    }
}

public extension UICollectionView {
    func dequeueReusableCell<TCell: UICollectionViewCell>(type: TCell.Type, for indexPath: IndexPath) -> TCell? {
        dequeueReusableCell(withReuseIdentifier: type.identifier, for: indexPath) as? TCell
    }
    
    func register<TCell: UICollectionViewCell>(_ cellClass: TCell.Type) {
        register(cellClass, forCellWithReuseIdentifier: cellClass.identifier)
    }
}
