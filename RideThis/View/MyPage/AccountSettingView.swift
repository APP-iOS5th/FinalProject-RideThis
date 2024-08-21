import UIKit
import SnapKit

class AccountSettingView: RideThisViewController {
    
    private lazy var logoImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "logo")
        image.contentMode = .scaleAspectFit
        let widthAndHeight = self.view.frame.width - 100
        image.widthAnchor.constraint(equalToConstant: widthAndHeight).isActive = true
        image.heightAnchor.constraint(equalToConstant: widthAndHeight).isActive = true
        
        return image
    }()
    private let loginAccountLabel = RideThisLabel(fontType: .defaultSize, text: "로그인 계정")
    private let loginAccount = RideThisLabel(fontType: .defaultSize, fontColor: .recordTitleColor, text: "test@gmail.com")
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
    }
    
    func setLogoImage() {
        self.view.addSubview(self.logoImage)
        
        self.logoImage.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(50)
            $0.centerX.equalTo(self.view.snp.centerX)
        }
    }
    
    func setAccountLabel() {
        [self.loginAccountLabel, self.loginAccount, self.accountSeparator].forEach{ self.view.addSubview($0) }
        
        //
        self.loginAccountLabel.snp.makeConstraints {
            $0.top.equalTo(self.logoImage.snp.bottom).offset(30)
            $0.left.equalTo(self.view.snp.left).offset(80)
        }
        
        self.loginAccount.snp.makeConstraints {
            $0.top.equalTo(self.loginAccountLabel.snp.top)
            $0.left.equalTo(self.loginAccountLabel.snp.right).offset(25)
        }
        
        self.accountSeparator.snp.makeConstraints {
            $0.top.equalTo(self.loginAccountLabel.snp.bottom).offset(10)
            $0.left.equalTo(self.loginAccountLabel.snp.left)
            $0.right.equalTo(self.loginAccount.snp.right)
        }
    }
    
    func setAccountButton() {
        self.view.addSubview(self.logoutButton)
        self.view.addSubview(self.quitAccountButton)
        
        self.logoutButton.snp.makeConstraints {
            $0.top.equalTo(self.accountSeparator.snp.bottom).offset(30)
            $0.centerX.equalTo(self.accountSeparator.snp.centerX)
        }
        
        self.quitAccountButton.snp.makeConstraints {
            $0.top.equalTo(self.logoutButton.snp.bottom).offset(10)
            $0.centerX.equalTo(self.logoutButton.snp.centerX)
        }
        
        self.quitAccountButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            let quitView = AccountQuitView()
            self.navigationController?.pushViewController(quitView, animated: true)
        }, for: .touchUpInside)
    }
}
