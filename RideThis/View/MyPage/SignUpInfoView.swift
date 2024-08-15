import UIKit

class SignUpInfoView: RideThisViewController {
    
    private let signUpTitle = RideThisLabel(fontType: .signUpFont, fontColor: .primaryColor, text: "라이더")
    private let signUpTitle2 = RideThisLabel(fontType: .signUpFont, text: "님 환영합니다.")
    private lazy var signUpTitleStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.addArrangedSubview(signUpTitle)
        stack.addArrangedSubview(signUpTitle2)
        stack.spacing = 3
        stack.distribution = .equalSpacing
        
        return stack
    }()
    private let signUpInfoLabel = RideThisLabel(text: "원활한 사용을 위해 추가 정보를 입력해주세요.")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    func configureUI() {
        setInfoLabel()
    }
    
    func setInfoLabel() {
        [signUpTitleStackView, signUpInfoLabel].forEach{ self.view.addSubview($0) }
        
        signUpTitleStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.centerX.equalTo(view.snp.centerX)
        }
        
        signUpInfoLabel.snp.makeConstraints {
            $0.top.equalTo(signUpTitleStackView.snp.bottom).offset(8)
            $0.centerX.equalTo(view.snp.centerX)
        }
    }
}
