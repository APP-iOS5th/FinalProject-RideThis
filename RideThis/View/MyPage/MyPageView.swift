import UIKit
import SnapKit

// 마이페이지 초기 화면
class MyPageView: RideThisViewController {
    
    // UIComponents
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        
        return scroll
    }()
    private let contentView: UIView = {
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        
        return content
    }()
    
    // Profile
    private let profileContainer = RideThisContainer(height: 100)
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.layer.cornerRadius = 40
        imageView.backgroundColor = .primaryColor
        
        return imageView
    }()
    // MARK: TODO - 팔로워 / 팔로잉 숫자가 커질 때 잘 대비 해야함.
    private let followerLabel = RideThisLabel(fontType: .profileFont, text: "팔로워")
    private let followerCountLabel = RideThisLabel(fontType: .profileFont, text: "30")
    private let followingLabel = RideThisLabel(fontType: .profileFont, text: "팔로잉")
    private let followingCountLabel = RideThisLabel(fontType: .profileFont, text: "35")
    private let notLoginLabel = RideThisLabel(fontType: .recordInfoTitle, text: "로그인이 필요합니다.")
    
    // User Info
    private let userInfoLabel = RideThisLabel(fontType: .profileFont, text: "정보")
    private lazy var profileEditButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("편집", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        btn.contentVerticalAlignment = .top
        
        return btn
    }()
    private let userInfoContainer = RideThisContainer(height: 150)
    private let firstSeparator = CustomSeparator()
    private let secondSeparator = CustomSeparator()
    private let userNickNameLabel = RideThisLabel(text: "닉네임")
    private let userHeightLabel = RideThisLabel(text: "키(cm)")
    private let userWeightLabel = RideThisLabel(text: "몸무게(kg)")
    private let userNickName = RideThisLabel(text: "매드카우")
    private let userHeight = RideThisLabel(text: "168")
    private let userWeight = RideThisLabel(text: "70")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSettingButton()
        setUIComponents()
    }
    
    func setSettingButton() {
        let settingButton = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: #selector(settingButtonTapAction))
        settingButton.tintColor = .label
        self.navigationItem.rightBarButtonItem = settingButton
    }
    
    func setUIComponents() {
        setScrollView()
        setProfileView()
        setUserInfoView()
    }
    
    func setScrollView() {
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.contentView)
        
        self.scrollView.snp.makeConstraints { [weak self] scroll in
            guard let self = self else { return }
            scroll.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            scroll.left.equalTo(self.view.snp.left)
            scroll.right.equalTo(self.view.snp.right)
            scroll.bottom.equalTo(self.view.snp.bottom)
        }
        
        self.contentView.snp.makeConstraints { [weak self] content in
            guard let self = self else { return }
            content.top.equalTo(self.scrollView.snp.top)
            content.left.equalTo(self.scrollView.snp.left)
            content.right.equalTo(self.scrollView.snp.right)
            content.bottom.equalTo(self.scrollView.snp.bottom)
            content.width.equalTo(self.scrollView.snp.width)
        }
    }
    
    func setProfileView() {
        self.contentView.addSubview(self.profileContainer)
        self.profileContainer.snp.makeConstraints { [weak self] container in
            guard let self = self else { return }
            container.top.equalTo(self.contentView.snp.top).offset(15)
            container.left.equalTo(self.contentView.snp.left).offset(25)
            container.right.equalTo(self.contentView.snp.right).offset(-25)
        }
        
        // MARK: TODO - 로그인의 여부에 따라서 프로필사진, 팔로워, 팔로잉 / "로그인이 필요합니다" 다르게 보이도록 분기처리
        setLoginProfileView()
    }
    
    func setLoginProfileView() {
        [self.profileImageView, self.followerLabel, self.followerCountLabel,
         self.followingLabel, self.followingCountLabel].forEach{ self.profileContainer.addSubview($0) }
        
        self.profileImageView.snp.makeConstraints { [weak self] image in
            guard let self = self else { return }
            image.top.equalTo(self.profileContainer.snp.top).offset(10)
            image.left.equalTo(self.profileContainer.snp.left).offset(10)
            image.bottom.equalTo(self.profileContainer.snp.bottom).offset(-10)
        }
        
        self.followerLabel.snp.makeConstraints { [weak self] label in
            guard let self = self else { return }
            label.top.equalTo(self.profileImageView.snp.top).offset(8)
            label.centerX.equalTo(self.profileContainer.snp.centerX)
        }
        
        self.followerCountLabel.snp.makeConstraints { [weak self] label in
            guard let self = self else { return }
            label.bottom.equalTo(self.profileImageView.snp.bottom).offset(-8)
            label.centerX.equalTo(self.profileContainer.snp.centerX)
        }
        
        self.followingLabel.snp.makeConstraints { [weak self] label in
            guard let self = self else { return }
            label.top.equalTo(self.profileImageView.snp.top).offset(8)
            label.right.equalTo(self.profileContainer.snp.right).offset(-40)
        }
        
        self.followingCountLabel.snp.makeConstraints { [weak self] label in
            guard let self = self else { return }
            label.bottom.equalTo(self.profileImageView.snp.bottom).offset(-8)
            label.centerX.equalTo(self.followingLabel.snp.centerX)
        }
    }
    
    func setNotLoginProfileView() {
        self.profileContainer.addSubview(self.notLoginLabel)
        
        self.notLoginLabel.snp.makeConstraints { [weak self] label in
            guard let self = self else { return }
            label.centerX.equalTo(self.profileContainer.snp.centerX)
            label.centerY.equalTo(self.profileContainer.snp.centerY)
        }
    }
    
    func setUserInfoView() {
        [self.userInfoLabel, self.profileEditButton, self.userInfoContainer].forEach{ self.contentView.addSubview($0) }
        
        self.userInfoLabel.snp.makeConstraints { [weak self] label in
            guard let self = self else { return }
            label.top.equalTo(self.profileContainer.snp.bottom).offset(20)
            label.left.equalTo(self.profileContainer.snp.left).offset(5)
        }
        
        self.profileEditButton.snp.makeConstraints { [weak self] button in
            guard let self = self else { return }
            button.centerY.equalTo(self.userInfoLabel.snp.centerY)
            button.right.equalTo(self.profileContainer.snp.right).offset(-5)
        }
        
        self.userInfoContainer.snp.makeConstraints { [weak self] container in
            guard let self = self else { return }
            container.top.equalTo(self.userInfoLabel.snp.bottom).offset(8)
            container.left.equalTo(self.userInfoLabel.snp.left)
            container.right.equalTo(self.profileEditButton.snp.right)
            container.bottom.equalTo(self.contentView.snp.bottom)
        }
        
        [self.firstSeparator, self.secondSeparator, self.userNickNameLabel,
         self.userHeightLabel, self.userWeightLabel, self.userNickName,
         self.userHeight, self.userWeight].forEach{ self.userInfoContainer.addSubview($0) }
        
        self.firstSeparator.snp.makeConstraints { [weak self] separator in
            guard let self = self else { return }
            separator.top.equalTo(self.userInfoContainer.snp.top).offset(50)
            separator.left.equalTo(self.userInfoContainer.snp.left)
            separator.right.equalTo(self.userInfoContainer.snp.right)
        }
        
        self.secondSeparator.snp.makeConstraints { [weak self] separator in
            guard let self = self else { return }
            separator.top.equalTo(self.firstSeparator.snp.top).offset(50)
            separator.left.equalTo(self.userInfoContainer.snp.left)
            separator.right.equalTo(self.userInfoContainer.snp.right)
        }
        
        self.userNickNameLabel.snp.makeConstraints { [weak self] label in
            guard let self = self else { return }
            label.top.equalTo(self.userInfoContainer.snp.top).offset(15)
            label.left.equalTo(self.userInfoContainer.snp.left).offset(10)
        }
        
        self.userHeightLabel.snp.makeConstraints { [weak self] label in
            guard let self = self else { return }
            label.centerY.equalTo(self.userInfoContainer.snp.centerY)
            label.left.equalTo(self.userNickNameLabel.snp.left)
        }
        
        self.userWeightLabel.snp.makeConstraints { [weak self] label in
            guard let self = self else { return }
            label.top.equalTo(self.secondSeparator.snp.bottom).offset(15)
            label.left.equalTo(self.userNickNameLabel.snp.left)
        }
        
        self.userNickName.snp.makeConstraints { [weak self] label in
            guard let self = self else { return }
            label.top.equalTo(self.userNickNameLabel.snp.top)
            label.left.equalTo(self.userNickNameLabel.snp.right).offset(60)
        }
        
        self.userHeight.snp.makeConstraints { [weak self] label in
            guard let self = self else { return }
            label.top.equalTo(self.userHeightLabel.snp.top)
            label.left.equalTo(self.userNickName.snp.left)
        }
        
        self.userWeight.snp.makeConstraints { [weak self] label in
            guard let self = self else { return }            
            label.top.equalTo(self.userWeightLabel.snp.top)
            label.left.equalTo(self.userNickName.snp.left)
        }
    }
    
    @objc func settingButtonTapAction() {
        
    }
}
