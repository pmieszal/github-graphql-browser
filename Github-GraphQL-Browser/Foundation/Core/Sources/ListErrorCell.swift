import UIKit

public struct ListErrorCellPresentable: Hashable {
    let id = UUID()
    let message: String
    
    public init(error: LocalizedError) {
        message = error.localizedDescription
    }
}

public class ListErrorCell: UITableViewCell {
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        textLabel?.font = .systemFont(ofSize: UIFont.labelFontSize, weight: .bold)
        textLabel?.numberOfLines = 0
        textLabel?.textAlignment = .center
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configureWithPresentable(_ presentable: ListErrorCellPresentable) {
        textLabel?.text = presentable.message
    }
}
