import UIKit
import FirebaseFirestore
import FirebaseStorage

class SignUpInfoView: RideThisViewController {
    
    // MARK: Data Components
    let userId: String
    let userEmail: String?
    private let userService = UserService()
    
    init(userId: String, userEmail: String?) {
        self.userId = userId
        self.userEmail = userEmail
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    private lazy var userEmailTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "이메일을 입력해주세요"
        tf.text = userEmail
        if userEmail != nil {
            tf.isEnabled = false
        }
        
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
    private let nextButton = RideThisButton(buttonTitle: "회원가입", height: 50)
    
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
        [signUpTitleStackView, signUpInfoLabel].forEach { self.view.addSubview($0) }
        
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
        [userEmailLabel, userEmailTextField, userInfoSeparator,
         userNickNameLabel, userNickName].forEach { userInfoContainer.addSubview($0) }
        
        userInfoContainer.snp.makeConstraints {
            $0.top.equalTo(signUpInfoLabel.snp.bottom).offset(30)
            $0.left.equalTo(view.snp.left).offset(20)
            $0.right.equalTo(view.snp.right).offset(-20)
        }
        
        userEmailLabel.snp.makeConstraints {
            $0.top.equalTo(self.userInfoContainer.snp.top).offset(15)
            $0.left.equalTo(self.userInfoContainer.snp.left).offset(10)
        }
        
        userEmailTextField.snp.makeConstraints {
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
            $0.left.equalTo(self.userEmailTextField.snp.left)
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
         userHeightLabel, userHeight, userInfoLabel2].forEach { userInfoContainer2.addSubview($0) }
        
        userWeightLabel.snp.makeConstraints {
            $0.top.equalTo(userInfoContainer2.snp.top).offset(15)
            $0.left.equalTo(userEmailLabel.snp.left)
        }
        
        userWeight.snp.makeConstraints {
            $0.top.equalTo(userWeightLabel.snp.top)
            $0.left.equalTo(userEmailTextField.snp.left)
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
        
        nextButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            // MARK: next버튼 누르면 Firebase에 저장
            let db = Firestore.firestore()
            let usersCollection = db.collection("USERS")
            let enteredEmail: String = userEmail ?? ""
            let enteredNickname: String = userNickName.text ?? ""
            
            let newUser: [String: Any] = [
                "user_account_public": false,
                "user_email": enteredEmail,
                "user_follower": [],
                "user_following": [],
                "user_id": userId,
                "user_image": "",
                "user_nickname": enteredNickname,
                "user_tall": Int(userHeight.text ?? "")!,
                "user_weight": Int(userWeight.text ?? "")!
            ]
            
            usersCollection.document(userId).setData(newUser) { error in
                if let error = error {
                    print("문서 생성 실패: \(error.localizedDescription)")
                } else {
                    print("문서 생성 및 필드 추가 성공")
                }
            }
            // MARK: TODO - 바로 로그인 시키기
            let createdUser = User(user_id: userId,
                                   user_image: "",
                                   user_email: enteredEmail,
                                   user_nickname: enteredNickname,
                                   user_weight: Int(userWeight.text!)!,
                                   user_tall: Int(userHeight.text!),
                                   user_following: [],
                                   user_follower: [],
                                   user_account_public: false)
            
            userService.signedUser = createdUser
            
            if let scene = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate) {
                scene.changeRootView(viewController: scene.getTabbarController(), animated: true)
            }
        }, for: .touchUpInside)
    }
}
