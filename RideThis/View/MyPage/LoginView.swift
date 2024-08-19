import UIKit
import SnapKit

class LoginView: RideThisViewController {
    
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
    private let chatLabel = RideThisLabel(fontType: .profileFont, text: "로그인해서 라이더의 체력을 향상시키세요.")
    private let loginButton = AppleLoginButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "계정 설정"
        view.addSubview(logoImage)
        view.addSubview(chatLabel)
        view.addSubview(loginButton)
        
        logoImage.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(50)
            $0.centerX.equalTo(view.snp.centerX)
        }
        
        chatLabel.snp.makeConstraints {
            $0.top.equalTo(logoImage.snp.bottom).offset(20)
            $0.centerX.equalTo(view.snp.centerX)
        }
        
        loginButton.snp.makeConstraints {
            $0.top.equalTo(chatLabel.snp.bottom).offset(20)
            $0.left.equalTo(view.snp.left).offset(15)
            $0.right.equalTo(view.snp.right).offset(-15)
        }
    }
}
