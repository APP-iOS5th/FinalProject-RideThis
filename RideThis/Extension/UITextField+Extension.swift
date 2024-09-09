import UIKit

class userInfoTextField: UITextField {
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureTextField()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureTextField()
    }
    
    func configureTextField() {
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension UITextField {
    func setKeyboardHider() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // MARK: 완료버튼을 오른쪽으로 두려고 왼쪽에 공백을 주는역할
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(doneButtonTapped))
        
        toolbar.items = [flexibleSpace, doneButton]
        
        self.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonTapped() {
        self.resignFirstResponder()
    }
}
