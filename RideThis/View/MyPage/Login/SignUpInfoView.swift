import UIKit
import FirebaseFirestore
import FirebaseStorage
import Combine

class SignUpInfoView: RideThisViewController {
    
    // MARK: Data Components
    let userId: String
    let userEmail: String?
//    let prevViewCase: ViewCase
    var signUpCoordinator: SignUpCoordinator?
    private let firebaseService = FireBaseService()
    private let viewModel = SignUpInfoViewModel()
    private lazy var cancellable = Set<AnyCancellable>()
    
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
        tf.autocapitalizationType = .none
        tf.text = userEmail
        tf.addTarget(self, action: #selector(textFieldValueChanged(_:)), for: .editingChanged)
        tf.setKeyboardHider()
        self.viewModel.emailText = userEmail ?? ""
        
        return tf
    }()
    private let userInfoSeparator = CustomSeparator()
    private let userNickNameLabel = RideThisLabel(text: "닉네임")
    private lazy var userNickName: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "닉네임을 입력해주세요."
        tf.addTarget(self, action: #selector(textFieldValueChanged(_:)), for: .editingChanged)
        tf.setKeyboardHider()
        
        tf.delegate = self
        
        return tf
    }()
    private let userInfoLabel = RideThisLabel(fontType: .smallTitle, text: "닉네임은 설정에서 언제든 수정 가능합니다.")
    
    // MARK: SignUp Info - 2
    private let userInfoContainer2 = RideThisContainer(height: 100)
    private let userWeightLabel = RideThisLabel(text: "몸무게(kg)")
    private lazy var userWeight: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "몸무게를 입력해주세요."
        tf.keyboardType = .numberPad
        tf.addTarget(self, action: #selector(textFieldValueChanged(_:)), for: .editingChanged)
        tf.setKeyboardHider()
        
        return tf
    }()
    private let userInfoSeparator2 = CustomSeparator()
    private let userHeightLabel = RideThisLabel(text: "키(cm)")
    private lazy var userHeight: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "키를 입력해주세요."
        tf.keyboardType = .numberPad
        tf.addTarget(self, action: #selector(textFieldValueChanged(_:)), for: .editingChanged)
        tf.setKeyboardHider()
        
        return tf
    }()
    private let userInfoLabel2 = RideThisLabel(fontType: .smallTitle, text: "키, 몸무게는 운동 시 칼로리 측정을 위해 입력해주세요.")
    
    // MARK: Next Button
    private let nextButton = RideThisButton(buttonTitle: "시작하기", height: 50)
    
    // 몸무게 Warning 문구
    private let weightWarningLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = .systemFont(ofSize: 12)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // tap 제스처
    private lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(hanlderTapGeture))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setBindingData()
    }
    
    // Memory TapGestures
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        self.view.addGestureRecognizer(tapGesture)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
//                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.removeGestureRecognizer(tapGesture)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func configureUI() {
        self.overrideUserInterfaceStyle = .light
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
         userNickNameLabel, userNickName].enumerated().forEach { (idx, ui) in
            userInfoContainer.addSubview(ui)
            if [3].contains(idx) {
                let mandatoryImgView = MandatoryMark(frame: .zero)
                
                userInfoContainer.addSubview(mandatoryImgView)
                mandatoryImgView.snp.makeConstraints {
                    $0.top.equalTo(ui.snp.top).offset(1.5)
                    $0.left.equalTo(ui.snp.right)
                }
            }
        }
        
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
         userHeightLabel, userHeight, userInfoLabel2].enumerated().forEach { (idx, ui) in
            userInfoContainer2.addSubview(ui)
            if idx == 0 {
                let mandatoryImgView = MandatoryMark(frame: .zero)
                
                userInfoContainer2.addSubview(mandatoryImgView)
                mandatoryImgView.snp.makeConstraints {
                    $0.top.equalTo(ui.snp.top).offset(1.5)
                    $0.left.equalTo(ui.snp.right)
                }
            }
        }
        
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
        nextButton.backgroundColor = self.viewModel.allFieldFilled ? .primaryColor : .lightGray
        nextButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            
            let enteredEmail: String = userEmailTextField.text ?? ""
            let enteredNickname: String = userNickName.text ?? ""
            
            let newUserInfo: [String: Any] = [
                "user_account_public": false,
                "user_alarm_status": true,
                "user_email": enteredEmail,
                "user_follower": [],
                "user_following": [],
                "user_id": userId,
                "user_image": "",
                "user_nickname": enteredNickname,
                "user_tall": userHeight.text!.isEmpty ? -1 : Int(userHeight.text!)!,
                "user_weight": Int(userWeight.text ?? "")!
            ]
            
            self.viewModel.createUser(userInfo: newUserInfo) { [weak self] user in
                guard let self = self else { return }
                UserService.shared.checkPrevAppleLogin()
                UserService.shared.signedUser = user
                
                self.dismiss(animated: true) {
                    if let coor = self.signUpCoordinator, coor.childCoordinators.count > 0 {
                        for coordinator in coor.childCoordinators {
                            if let loginCoor = coordinator as? LoginCoordinator {
                                if loginCoor.prevViewCase == .summary {
                                    loginCoor.navigationController.popViewController(animated: false)
                                    loginCoor.changeButton(afterLogin: true)
                                    Task {
                                        await self.firebaseService.saveNoUserRecordData(user: user) {}
                                    }
                                    break
                                } else {
                                    loginCoor.navigationController.popViewController(animated: false)
                                }
                            }
                        }
                    }
                }
            }
        }, for: .touchUpInside)
        
        
        // 몸무게 Warning
        self.view.addSubview(weightWarningLabel)
        
        weightWarningLabel.snp.makeConstraints {
            $0.bottom.equalTo(nextButton.snp.top).offset(-10)
            $0.centerX.equalTo(self.view.snp.centerX)
        }
    }
    
    func setBindingData() {
        viewModel.$allFieldFilled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] filled in
                guard let self = self else { return }
                nextButton.isEnabled = filled
                nextButton.backgroundColor = filled ? .primaryColor : .lightGray
            }
            .store(in: &cancellable)
        
        viewModel.$isExistNickName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] exist in
                guard let self = self else { return }
                
                if exist {
                    userNickName.textColor = .systemRed
                } else {
                    userNickName.textColor = .label
                }
            }
            .store(in: &cancellable)
        
        viewModel.$isExistEmail
            .receive(on: DispatchQueue.main)
            .sink { [weak self] exist in
                guard let self = self else { return }
                
                if exist {
                    userEmailTextField.textColor = .systemRed
                } else {
                    userEmailTextField.textColor = .label
                }
            }
            .store(in: &cancellable)
        
        self.viewModel.$weightWarningText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] warningText in
                guard let self = self else { return }
                self.weightWarningLabel.text = warningText
                self.weightWarningLabel.isHidden = warningText == nil
            }
            .store(in: &cancellable)
    }
    
    @objc func textFieldValueChanged(_ sender: UITextField) {
        switch sender {
        case self.userEmailTextField:
            self.viewModel.emailText = sender.text ?? ""
        case self.userNickName:
            self.viewModel.nickNameText = sender.text ?? ""
        case self.userWeight:
            if let text = sender.text, text.count > 3 {
                sender.text?.removeLast()
            }
            self.viewModel.weightText = sender.text ?? ""
        case self.userHeight:
            if let text = sender.text, text.count > 3 {
                sender.text?.removeLast()
            }
        default:
            print("default")
            break
        }
    }
    

    // MARK: KeyboardDelegate
    @objc func keyboardWillHide(_ notification: NSNotification) {
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
    
    @objc func hanlderTapGeture(_ sender: UIView) {
        userEmailTextField.resignFirstResponder()
        userNickName.resignFirstResponder()
        userWeight.resignFirstResponder()
        userHeight.resignFirstResponder()
    }
}

// MARK: UITextFieldDelegate
extension SignUpInfoView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == userNickName {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            _ = currentText.replacingCharacters(in: stringRange, with: string)
            
            if string.contains(" ") {
                return false
            }
            
            let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            if text.count > 7 {
                textField.text = String(text.prefix(7))
                return false
            }
            
            return true
        }
        return true
    }
}
