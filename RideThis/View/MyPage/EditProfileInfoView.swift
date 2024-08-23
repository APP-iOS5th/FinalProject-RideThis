import UIKit
import Combine
import SnapKit
import Kingfisher

class EditProfileInfoView: RideThisViewController {
    
    // MARK: Data Components
    var user: User
    private let firebaseService = FireBaseService()
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UI Components
    private lazy var profileImageView: UIImageView = {
        // TODO: 이미지를 탭 했을 때 이미지(사용자 사진첩)를 변경할 수 있는 화면
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        imageView.layer.cornerRadius = 60
        imageView.clipsToBounds = true
        if let imageURL = self.user.user_image {
            imageView.kf.setImage(with: URL(string: imageURL))
        }
        imageView.backgroundColor = .primaryColor
        
        return imageView
    }()
    private let cameraImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        imageView.image = UIImage(systemName: "camera")
        imageView.tintColor = .primaryColor
        
        return imageView
    }()
    private let profileInfoContainer = RideThisContainer(height: 150)
    private let firstSeparator = CustomSeparator()
    private let secondSeparator = CustomSeparator()
    private let userNickNameLabel = RideThisLabel(text: "닉네임")
    private let userHeightLabel = RideThisLabel(text: "키(cm)")
    private let userWeightLabel = RideThisLabel(text: "몸무게(kg)")
    private lazy var userNickNameTextField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = self.user.user_nickname
        field.text = self.user.user_nickname
        field.tag = 0
        field.addTarget(self, action: #selector(userNickNameChanged), for: .editingChanged)
        
        return field
    }()
    private lazy var userHeightTextField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = self.user.tallStr
        field.text = self.user.tallStr
        
        return field
    }()
    private lazy var userWeightTextField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = "\(self.user.user_weight)"
        field.text = "\(self.user.user_weight)"
        field.tag = 1
        field.addTarget(self, action: #selector(userNickNameChanged), for: .editingChanged)
        
        return field
    }()
    
    // Data Components
    private let editViewModel = EditProfileInfoViewModel()
    private var cancellable = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationComponents()
        setUIComponents()
    }
    
    func setNavigationComponents() {
        self.title = "프로필 편집"
        // MARK: TODO - 필수 입력항목이 입력되지 않으면 비활성화
        let saveButton = UIBarButtonItem(title: "저장", style: .plain, target: self, action: #selector(saveProfileInfo))
        self.navigationItem.rightBarButtonItem = saveButton
    }
    
    func setUIComponents() {
        setProfileImage()
        setProfileInfoView()
    }
    
    func setProfileImage() {
        [self.profileImageView, self.cameraImageView].forEach{ self.view.addSubview($0) }
        
        self.profileImageView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.centerX.equalTo(self.view.snp.centerX)
        }
        
        self.cameraImageView.snp.makeConstraints {
            $0.bottom.equalTo(self.profileImageView.snp.bottom)
            $0.right.equalTo(self.profileImageView.snp.right).offset(-15)
        }
    }
    
    func setProfileInfoView() {
        self.view.addSubview(self.profileInfoContainer)
        
        self.profileInfoContainer.snp.makeConstraints {
            $0.top.equalTo(self.profileImageView.snp.bottom).offset(20)
            $0.left.equalTo(self.view.snp.left).offset(20)
            $0.right.equalTo(self.view.snp.right).offset(-20)
        }
        
        [self.firstSeparator, self.secondSeparator, self.userNickNameLabel,
         self.userHeightLabel, self.userWeightLabel, self.userNickNameTextField,
         self.userHeightTextField, self.userWeightTextField].forEach{ self.profileInfoContainer.addSubview($0) }
        
        self.userNickNameLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        self.userNickNameTextField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        self.userHeightLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        self.userHeightTextField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        self.userWeightLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        self.userWeightTextField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        self.userNickNameLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.userNickNameTextField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        self.userHeightLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.userHeightTextField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        self.userWeightLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.userWeightTextField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        self.firstSeparator.snp.makeConstraints {
            $0.top.equalTo(self.profileInfoContainer.snp.top).offset(50)
            $0.left.equalTo(self.profileInfoContainer.snp.left).offset(15)
            $0.right.equalTo(self.profileInfoContainer.snp.right).offset(-15)
        }
        
        self.secondSeparator.snp.makeConstraints {
            $0.top.equalTo(self.firstSeparator.snp.bottom).offset(50)
            $0.left.equalTo(self.profileInfoContainer.snp.left).offset(15)
            $0.right.equalTo(self.profileInfoContainer.snp.right).offset(-15)
        }
        
        self.userNickNameLabel.snp.makeConstraints { [weak self] label in
            guard let self = self else { return }
            label.top.equalTo(self.profileInfoContainer.snp.top).offset(15)
            label.left.equalTo(self.profileInfoContainer.snp.left).offset(10)
        }
        
        self.userHeightLabel.snp.makeConstraints {
            $0.centerY.equalTo(self.profileInfoContainer.snp.centerY)
            $0.left.equalTo(self.userNickNameLabel.snp.left)
        }
        
        self.userWeightLabel.snp.makeConstraints { [weak self] label in
            guard let self = self else { return }
            label.top.equalTo(self.secondSeparator.snp.bottom).offset(15)
            label.left.equalTo(self.userNickNameLabel.snp.left)
        }
        
        self.userNickNameTextField.snp.makeConstraints {
            $0.centerY.equalTo(self.userNickNameLabel.snp.centerY)
            $0.left.equalTo(self.userNickNameLabel.snp.right).offset(60)
            $0.right.equalTo(self.profileInfoContainer.snp.right).offset(-10)
        }
        
        self.userHeightTextField.snp.makeConstraints {
            $0.centerY.equalTo(self.userHeightLabel.snp.centerY)
            $0.left.equalTo(self.userNickNameTextField.snp.left)
            $0.right.equalTo(self.profileInfoContainer.snp.right).offset(-10)
        }
        
        self.userWeightTextField.snp.makeConstraints {
            $0.centerY.equalTo(self.userWeightLabel.snp.centerY)
            $0.left.equalTo(self.userNickNameTextField.snp.left)
            $0.right.equalTo(self.profileInfoContainer.snp.right).offset(-10)
        }
    }
    
    @objc func saveProfileInfo() {
        // MARK: TODO -
        let changedUser = User(user_id: user.user_id,
                               user_image: user.user_image,
                               user_email: user.user_email,
                               user_nickname: self.userNickNameTextField.text!,
                               user_weight: Int(self.userWeightTextField.text!)!,
                               user_tall: Int(self.userHeightTextField.text!),
                               user_following: user.user_following,
                               user_follower: user.user_follower,
                               user_account_public: user.user_account_public)
        
        firebaseService.updateUserInfo(updated: changedUser)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func userNickNameChanged(sender: UITextField) {
        
    }
}
