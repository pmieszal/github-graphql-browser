import UIKit

final class ChooseOwnerViewController: UIViewController {
    lazy var ownerTextField = UITextField()
    lazy var doneButton = UIButton()
    var navigation: ChooseOwnerNavigation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

private extension ChooseOwnerViewController {
    func setup() {
        view.backgroundColor = .systemBackground
        navigationItem.title = ChooseOwnerStrings.chooseOwnerTitle
        
        ownerTextField.font = .systemFont(ofSize: 28, weight: .regular)
        ownerTextField.borderStyle = .roundedRect
        ownerTextField.autocapitalizationType = .none
        ownerTextField.autocorrectionType = .no
        
        doneButton.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
        doneButton.setTitle(ChooseOwnerStrings.chooseOwnerDoneButtonTitle, for: .normal)
        doneButton.setTitleColor(.label, for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 24, weight: .heavy)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 32
        stackView.addArrangedSubview(ownerTextField)
        stackView.addArrangedSubview(doneButton)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            ownerTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        view.addGestureRecognizer(tap)
    }
    
    @objc
    func didTapDone() {
        navigation?.chooseOwnerDidSelectOwner(ownerTextField.text ?? "")
    }
    
    @objc
    func endEditing() {
        view.endEditing(true)
    }
}
