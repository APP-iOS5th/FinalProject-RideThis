import UIKit
import SnapKit

class AccountSettingView: RideThisViewController {
    
    var coordinator: AccountSettingCoordinator?
    private let service = UserService.shared
    private lazy var logoImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "logoTransparentWithName")
        image.contentMode = .scaleAspectFit
        let widthAndHeight = self.view.frame.width - 100
        image.widthAnchor.constraint(equalToConstant: widthAndHeight).isActive = true
        image.heightAnchor.constraint(equalToConstant: widthAndHeight).isActive = true
        
        return image
    }()
    private let loginAccountLabel = RideThisLabel(fontType: .defaultSize, text: "로그인 계정")
    private let loginAccount = RideThisLabel(fontType: .defaultSize, fontColor: .recordTitleColor)
    private lazy var loginStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.addArrangedSubview(loginAccountLabel)
        stack.addArrangedSubview(loginAccount)
        stack.spacing = 5
        stack.distribution = .fillProportionally
        stack.alignment = .center
        
        return stack
    }()
    private let accountSeparator = CustomSeparator()
    private let logoutButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.widthAnchor.constraint(equalToConstant: 150).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btn.setTitle("로그아웃", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.layer.cornerRadius = 12
        btn.backgroundColor = .lightGray
        
        return btn
    }()
    private let quitAccountButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("회원탈퇴", for: .normal)
        btn.setTitleColor(.red, for: .normal)
        btn.backgroundColor = .clear
        
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "계정 설정"
        configureUI()
    }
    
    func configureUI() {
        setLogoImage()
        setAccountLabel()
        setAccountButton()
        setUserData()
    }
    
    func setLogoImage() {
        self.view.addSubview(self.logoImage)
        
        self.logoImage.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(50)
            $0.centerX.equalTo(self.view.snp.centerX)
        }
    }
    
    func setAccountLabel() {
        [loginStack, self.accountSeparator].forEach{ self.view.addSubview($0) }
        
        loginStack.snp.makeConstraints {
            $0.centerX.equalTo(view.snp.centerX)
            $0.top.equalTo(self.logoImage.snp.bottom).offset(30)
        }
        
        self.accountSeparator.snp.makeConstraints {
            $0.top.equalTo(self.loginAccountLabel.snp.bottom).offset(10)
            $0.left.equalTo(self.view.snp.left).offset(70)
            $0.right.equalTo(self.view.snp.right).offset(-70)
        }
    }
    
    func setAccountButton() {
        self.view.addSubview(self.logoutButton)
        self.view.addSubview(self.quitAccountButton)
        
        self.logoutButton.snp.makeConstraints {
            $0.top.equalTo(self.accountSeparator.snp.bottom).offset(30)
            $0.centerX.equalTo(self.view.snp.centerX)
        }
        
        self.quitAccountButton.snp.makeConstraints {
            $0.top.equalTo(self.logoutButton.snp.bottom).offset(10)
            $0.centerX.equalTo(self.view.snp.centerX)
        }
        
        self.logoutButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.showAlert(alertTitle: "알림", msg: "정말 로그아웃 하시겠습니까?", confirm: "예") {
                self.service.logout()
            }
        }, for: .touchUpInside)
        
        self.quitAccountButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            
            let quitCoordinator = AccountQuitCoordinator(navigationController: self.navigationController!)
            quitCoordinator.start()
        }, for: .touchUpInside)
    }
    
    func setUserData() {
        guard let user = service.combineUser else { return }
        self.loginAccount.text = user.user_email
    }
}
