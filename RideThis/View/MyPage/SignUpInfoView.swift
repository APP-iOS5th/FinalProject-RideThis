import UIKit

class SignUpInfoView: RideThisViewController {
    
    // MARK: UI Components
    // MARK: SignUp Title
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
    // MARK: SignUp Info - 1
    private let userInfoContainer = RideThisContainer(height: 100)
    private let userEmailLabel = RideThisLabel(text: "이메일")
    private let userEmail: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "이메일을 입력해주세요"
        
        return tf
    }()
    private let userInfoSeparator = CustomSeparator()
    private let userNickNameLabel = RideThisLabel(text: "닉네임")
    private let userNickName: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "닉네임을 입력해주세요."
        
        return tf
    }()
    private let userInfoLabel = RideThisLabel(fontType: .smallTitle, text: "닉네임은 설정에서 언제든 수정 가능합니다.")
    // MARK: SignUp Info - 2
    private let userInfoContainer2 = RideThisContainer(height: 100)
    private let userWeightLabel = RideThisLabel(text: "몸무게(kg)")
    private let userWeight: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "몸무게를 입력해주세요."
        
        return tf
    }()
    private let userInfoSeparator2 = CustomSeparator()
    private let userHeightLabel = RideThisLabel(text: "키(cm)")
    private let userHeight: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "키를 입력해주세요."
        
        return tf
    }()
    private let userInfoLabel2 = RideThisLabel(fontType: .smallTitle, text: "키, 몸무게는 운동 시 칼로리 측정을 위해 입력해주세요.")
    // MARK: Next Button
    private let nextButton = RideThisButton(buttonTitle: "다음", height: 50)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    func configureUI() {
        setInfoLabel()
        setInfoContainer()
        setNextButton()
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
    
    func setInfoContainer() {
        view.addSubview(userInfoContainer)
        [userEmailLabel, userEmail, userInfoSeparator,
         userNickNameLabel, userNickName].forEach{ userInfoContainer.addSubview($0) }
        
        userInfoContainer.snp.makeConstraints {
            $0.top.equalTo(signUpInfoLabel.snp.bottom).offset(30)
            $0.left.equalTo(view.snp.left).offset(20)
            $0.right.equalTo(view.snp.right).offset(-20)
        }
        
        userEmailLabel.snp.makeConstraints {
            $0.top.equalTo(self.userInfoContainer.snp.top).offset(15)
            $0.left.equalTo(self.userInfoContainer.snp.left).offset(10)
        }
        
        userEmail.snp.makeConstraints {
            $0.top.equalTo(self.userEmailLabel.snp.top)
            $0.left.equalTo(self.userEmailLabel.snp.right).offset(60)
        }
        
        userInfoSeparator.snp.makeConstraints {
            $0.centerY.equalTo(userInfoContainer.snp.centerY)
            $0.left.equalTo(userInfoContainer.snp.left).offset(10)
            $0.right.equalTo(userInfoContainer.snp.right).offset(-10)
        }
        
        userNickNameLabel.snp.makeConstraints {
            $0.top.equalTo(self.userInfoSeparator.snp.bottom).offset(15)
            $0.left.equalTo(self.userEmailLabel.snp.left)
        }
        
        userNickName.snp.makeConstraints {
            $0.top.equalTo(self.userNickNameLabel.snp.top)
            $0.left.equalTo(self.userEmail.snp.left)
        }
        
        view.addSubview(userInfoLabel)
        
        userInfoLabel.snp.makeConstraints {
            $0.top.equalTo(userInfoContainer.snp.bottom).offset(5)
            $0.left.equalTo(userEmailLabel.snp.left)
        }
        
        view.addSubview(userInfoContainer2)
        
        userInfoContainer2.snp.makeConstraints {
            $0.top.equalTo(userInfoLabel.snp.bottom).offset(40)
            $0.left.equalTo(userInfoContainer.snp.left)
            $0.right.equalTo(userInfoContainer.snp.right)
        }
        
        [userWeightLabel, userWeight, userInfoSeparator2,
         userHeightLabel, userHeight, userInfoLabel2].forEach{ userInfoContainer2.addSubview($0) }
        
        userWeightLabel.snp.makeConstraints {
            $0.top.equalTo(userInfoContainer2.snp.top).offset(15)
            $0.left.equalTo(userEmailLabel.snp.left)
        }
        
        userWeight.snp.makeConstraints {
            $0.top.equalTo(userWeightLabel.snp.top)
            $0.left.equalTo(userEmail.snp.left)
        }
        
        userInfoSeparator2.snp.makeConstraints {
            $0.centerY.equalTo(userInfoContainer2.snp.centerY)
            $0.left.equalTo(userInfoSeparator.snp.left)
            $0.right.equalTo(userInfoSeparator.snp.right)
        }
        
        userHeightLabel.snp.makeConstraints {
            $0.top.equalTo(userInfoSeparator2.snp.top).offset(15)
            $0.left.equalTo(userWeightLabel.snp.left)
        }
        
        userHeight.snp.makeConstraints {
            $0.top.equalTo(userHeightLabel.snp.top)
            $0.left.equalTo(userNickName.snp.left)
        }
        
        userInfoLabel2.snp.makeConstraints {
            $0.top.equalTo(userInfoContainer2.snp.bottom).offset(5)
            $0.left.equalTo(userInfoLabel.snp.left)
        }
    }
    
    func setNextButton() {
        view.addSubview(nextButton)
        
        nextButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
            $0.left.equalTo(userInfoContainer.snp.left)
            $0.right.equalTo(userInfoContainer.snp.right)
        }
    }
}
