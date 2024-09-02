import UIKit
import Combine
import SnapKit
import Kingfisher

class EditProfileInfoView: RideThisViewController {
    
    // MARK: Data Components
    private let firebaseService = FireBaseService()
    var user: User
    let viewModel: EditProfileInfoViewModel
    var selectedUserImage: UIImage? = nil
    var updateImageDelegate: ProfileImageUpdateDelegate?
    var editProfileCoordinator: EditProfileCoordinator?
    
    init(user: User, viewModel: EditProfileInfoViewModel) {
        self.user = user
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UI Components
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 60
        imageView.clipsToBounds = true
        if let imageURL = self.user.user_image {
            if imageURL.isEmpty {
                imageView.image = UIImage(named: "bokdonge")
            } else {
                imageView.kf.setImage(with: URL(string: imageURL))
            }
        }
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    private let cameraImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        imageView.image = UIImage(systemName: "camera")
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
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
        field.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        return field
    }()
    private lazy var userHeightTextField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = self.user.tallStr
        field.text = self.user.tallStr
        field.keyboardType = .numberPad
        field.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        return field
    }()
    private lazy var userWeightTextField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = "\(self.user.user_weight)"
        field.text = "\(self.user.user_weight)"
        field.keyboardType = .numberPad
        field.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        return field
    }()
    let imagePickerController = UIImagePickerController()
    
    // Data Components
    private let editViewModel = EditProfileInfoViewModel()
    private var cancellable = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationComponents()
        setUIComponents()
        setBindingData()
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
        setProfileImageTapEvent()
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
         self.userHeightTextField, self.userWeightTextField].enumerated().forEach{ (idx, ui) in
            self.profileInfoContainer.addSubview(ui)
            if [2, 4].contains(idx) {
                let mandatoryImgView = MandatoryMark(frame: .zero)
                
                profileInfoContainer.addSubview(mandatoryImgView)
                mandatoryImgView.snp.makeConstraints {
                    $0.top.equalTo(ui.snp.top).offset(1.5)
                    $0.left.equalTo(ui.snp.right)
                }
            }
        }
        
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
        
        self.viewModel.nickName = self.user.user_nickname
        self.viewModel.weight = self.user.tallStr
    }
    
    func setProfileImageTapEvent() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openPhotoLibrary))
        self.profileImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func saveProfileInfo() {
        self.user.user_nickname = self.userNickNameTextField.text!
        self.user.user_weight = Int(self.userWeightTextField.text!)!
        self.user.user_tall = self.userHeightTextField.text! == "-" ? -1 : Int(self.userHeightTextField.text!)!
        
        self.firebaseService.updateUserInfo(updated: self.user, update: true)
        if let img = selectedUserImage {
            updateImageDelegate?.imageUpdate(image: img)
            firebaseService.saveImage(image: img, userId: user.user_id) { imgUrl in
                self.user.user_image = imgUrl.absoluteString
                self.firebaseService.updateUserInfo(updated: self.user, update: false)
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func setBindingData() {
        viewModel.$allFieldFilled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] filled in
                guard let self = self else { return }
                if let editButton = self.navigationItem.rightBarButtonItem {
                    editButton.isEnabled = filled
                }
            }
            .store(in: &cancellable)
        
        viewModel.$isExistNickName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] exist in
                guard let self = self else { return }
                
                if exist {
                    userNickNameTextField.textColor = .systemRed
                } else {
                    userNickNameTextField.textColor = .label
                }
            }
            .store(in: &cancellable)
    }
    
    @objc func textFieldChanged(sender: UITextField) {
        switch sender {
        case self.userNickNameTextField:
            self.viewModel.nickName = sender.text!
        case self.userHeightTextField:
            if let text = sender.text, text.count > 3 {
                sender.text?.removeLast()
            }
        case self.userWeightTextField:
            self.viewModel.weight = sender.text!
            if let text = sender.text, text.count > 3 {
                sender.text?.removeLast()
            }
        default:
            break
        }
    }
    
    @objc func openPhotoLibrary() {
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        present(imagePickerController, animated: true, completion: nil)
    }
}

extension EditProfileInfoView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // 사용자가 이미지를 선택했을 때 호출되는 함수
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 선택한 이미지 가져오기
        if let selectedImage = info[.originalImage] as? UIImage {
            selectedUserImage = selectedImage
            DispatchQueue.main.async {
                self.profileImageView.image = selectedImage
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }

    // 사용자가 취소했을 때 호출되는 함수
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
