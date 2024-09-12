import UIKit


class RideThisButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureButton()
    }
    

    convenience init(
        buttonTitle: String,
        height: CGFloat = 50
    ) {
        self.init()
        
        self.setTitle(buttonTitle, for: .normal)
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func configureButton() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 13
        self.backgroundColor = .primaryColor
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
    }
}

class AppleLoginButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureButton()
    }
    
    func configureButton() {
        self.translatesAutoresizingMaskIntoConstraints = false
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(named: "apple_logo")?.withTintColor(.white)
        configuration.imagePadding = 8
        
        self.configuration = configuration
        self.imageView?.contentMode = .scaleAspectFit
        self.setTitle("Sign in with Apple", for: .normal)
        self.setTitleColor(.white, for: .normal)
        self.tintColor = .black
        self.backgroundColor = .black
        self.layer.cornerRadius = 12
        self.heightAnchor.constraint(equalToConstant: 54).isActive = true
    }
}
