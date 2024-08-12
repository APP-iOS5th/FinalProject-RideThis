import UIKit
import SnapKit

class EditProfileInfoView: RideThisViewController {
    
    private let profileImageView: UIImageView = {
        // MARK: TODO - 이미지를 탭 했을 때 이미지(사용자 사진첩)를 변경할 수 있는 화면
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        imageView.layer.cornerRadius = 60
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
        imageView.tintColor = .black
        
        return imageView
    }()
    private let profileInfoContainer = RideThisContainer(height: 150)
    private let firstSeparator = CustomSeparator()
    private let secondSeparator = CustomSeparator()
    private let userNickNameLabel = RideThisLabel(text: "닉네임")
    private let userHeightLabel = RideThisLabel(text: "키(cm)")
    private let userWeightLabel = RideThisLabel(text: "몸무게(kg)")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "프로필 편집"
        setNavigationComponents()
        setUIComponents()
    }
    
    func setNavigationComponents() {
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
         self.userHeightLabel, self.userWeightLabel].forEach{ self.profileInfoContainer.addSubview($0) }
        
        self.firstSeparator.snp.makeConstraints {
            $0.top.equalTo(self.profileInfoContainer.snp.top).offset(50)
            $0.left.equalTo(self.profileInfoContainer.snp.left)
            $0.right.equalTo(self.profileInfoContainer.snp.right)
        }
        
        self.secondSeparator.snp.makeConstraints {
            $0.top.equalTo(self.firstSeparator.snp.bottom).offset(50)
            $0.left.equalTo(self.profileInfoContainer.snp.left)
            $0.right.equalTo(self.profileInfoContainer.snp.right)
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
    }
    
    @objc func saveProfileInfo() {
        self.navigationController?.popViewController(animated: true)
    }
}
