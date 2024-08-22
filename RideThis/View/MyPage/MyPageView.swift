import UIKit
import Kingfisher
import SnapKit
import FirebaseFirestore
import Combine

// 마이페이지 초기 화면
class MyPageView: RideThisViewController {
    
    // MARK: Data Components
    let viewModel = MyPageViewModel()
    let service = UserService.shared
    private var cancellable = Set<AnyCancellable>()
    
    // MARK: UIComponents
    // MARK: ScrollView
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
    
    // MARK: Profile
    private let profileContainer = RideThisContainer(height: 100)
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.layer.cornerRadius = 40
        imageView.clipsToBounds = true
        imageView.backgroundColor = .primaryColor
        
        return imageView
    }()
    // MARK: TODO - 팔로워 / 팔로잉 숫자가 커질 때 잘 대비 해야함.
    private let followerLabel = RideThisLabel(fontType: .profileFont, text: "팔로워")
    private let followerCountLabel = RideThisLabel(fontType: .profileFont)
    private let followingLabel = RideThisLabel(fontType: .profileFont, text: "팔로잉")
    private let followingCountLabel = RideThisLabel(fontType: .profileFont)
    private let notLoginLabel = RideThisLabel(fontType: .recordInfoTitle, text: "로그인이 필요합니다.")
    private let loginButton = RideThisButton(buttonTitle: "로그인", height: 50)
    
    // MARK: User Info
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
    private let userNickName = RideThisLabel()
    private let userHeight = RideThisLabel()
    private let userWeight = RideThisLabel()
    
    // MARK: Total Record
    private let totalRecordLabel = RideThisLabel(fontType: .profileFont, text: "With. RideThis")
    private let totalRecordContainer = RideThisContainer(height: 100)
    private let totalRunCount = RideThisLabel(fontColor: .recordTitleColor, text: "총 달린 횟수")
    private let totalRunCountSeparator = RideThisSeparator()
    private lazy var totalRunCountData = RideThisLabel(fontType: .classification, text: "3회"/*"\(self.user.record_id.count)회"*/)
    private let totalRunTime = RideThisLabel(fontColor: .recordTitleColor, text: "총 달린 시간")
    private let totalRunTimeSeparator = RideThisSeparator()
    private let totalRunTimeData = RideThisLabel(fontType: .classification, text: "2시간 15분")
    private let totalRunDistance = RideThisLabel(fontColor: .recordTitleColor, text: "총 달린 거리")
    private let totalRunDistanceSeparator = RideThisSeparator()
    private lazy var totalRunDistanceData = RideThisLabel(fontType: .classification, text: "test123km")
    
    // MARK: Record By Period
    private let recordByPeriodLabel = RideThisLabel(fontType: .profileFont, text: "기간별 기록")
    private lazy var recordByPeriodDetailButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("자세히 보기", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        btn.contentVerticalAlignment = .top
        
        return btn
    }()
    private let periodOptions: [String] = ["1주", "1개월", "3개월", "6개월"]
    private lazy var recordByPeriodPicker: UISegmentedControl = {
        let picker = UISegmentedControl(items: self.periodOptions)
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.selectedSegmentIndex = 0
        picker.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        
        return picker
    }()
    private let dataLabel = RideThisLabel(fontType: .profileFont, text: "Cadence")
    private lazy var graphCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = itemSize
        layout.minimumLineSpacing = itemSpacing
        layout.minimumInteritemSpacing = 0
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.dataSource = self
        collection.delegate = self
        collection.register(GraphCollectionViewCell.self, forCellWithReuseIdentifier: "GraphCollectionViewCell")
        collection.isScrollEnabled = true
        collection.showsHorizontalScrollIndicator = false
        collection.showsVerticalScrollIndicator = false
        collection.backgroundColor = .clear
        collection.clipsToBounds = true
        collection.isPagingEnabled = false
        collection.contentInsetAdjustmentBehavior = .never
        collection.decelerationRate = .fast
        
        return collection
    }()
    private lazy var pagingIndicator: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.alignment = .center
        stack.backgroundColor = .systemGray5
        stack.layer.cornerRadius = 12.5
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)

        for i in 0..<graphSectionCount {
            let dotImage = UIImageView(image: UIImage(systemName: "circle.fill"))
            dotImage.contentMode = .scaleAspectFit
            dotImage.translatesAutoresizingMaskIntoConstraints = false
            dotImage.widthAnchor.constraint(equalToConstant: 12).isActive = true
            dotImage.heightAnchor.constraint(equalToConstant: 12).isActive = true

            if i == 0 {
                dotImage.tintColor = .primaryColor
            } else {
                dotImage.tintColor = .lightGray
            }
            
            stack.addArrangedSubview(dotImage)
        }
        
        return stack
    }()
    private let selectedPeriodTotalRecordContainer = RideThisContainer(height: 150)
    private let selectedPeriodTitle = RideThisLabel(fontType: .recordInfoTitle, text: "Cadence")
    private let selectedPeriodSeparator = RideThisSeparator()
    private let selectedPeriodData = RideThisLabel(fontType: .title)
    private var selectedPeriodDataUnit = ShowingData.cadence.unit
    
    // MARK: Data for UI
    let graphSectionCount = 4
    lazy var itemSize = CGSize(width: self.view.frame.width - 65, height: 400)
    let itemSpacing = 15.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "마이페이지"
        setUIComponents()
        setUserData()
        setCombineData()
    }
    
    func setNavigationComponents() {
        let settingButton = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: #selector(settingButtonTapAction))
        settingButton.tintColor = .label
        self.navigationItem.rightBarButtonItem = settingButton
    }
    
    func setUIComponents() {
        for subview in view.subviews {
            subview.removeFromSuperview()
        }
        if service.signedUser == nil {
            setLoginComponents()
        } else {
            setNavigationComponents()
            setScrollView()
            setProfileView()
            setUserInfoView()
            setTotalRecordView()
            setRecordByPeriodView()
            setEventToProfileContainer()
        }
    }
    
    func setLoginComponents() {
        view.addSubview(notLoginLabel)
        view.addSubview(loginButton)
        
        notLoginLabel.snp.makeConstraints {
            $0.centerY.equalTo(view.snp.centerY)
            $0.centerX.equalTo(view.snp.centerX)
        }
        
        loginButton.snp.makeConstraints {
            $0.top.equalTo(notLoginLabel.snp.bottom).offset(10)
            $0.left.equalTo(view.snp.left).offset(30)
            $0.right.equalTo(view.snp.right).offset(-30)
        }
        
        loginButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.navigationController?.pushViewController(LoginView(), animated: true)
        }, for: .touchUpInside)
    }
    
    func setScrollView() {
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.contentView)
        
        self.scrollView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.left.equalTo(self.view.snp.left)
            $0.right.equalTo(self.view.snp.right)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        
        self.contentView.snp.makeConstraints {
            $0.top.equalTo(self.scrollView.snp.top)
            $0.left.equalTo(self.scrollView.snp.left)
            $0.right.equalTo(self.scrollView.snp.right)
            $0.bottom.equalTo(self.scrollView.snp.bottom)
            $0.width.equalTo(self.scrollView.snp.width)
        }
    }
    
    func setProfileView() {
        self.contentView.addSubview(self.profileContainer)
        self.profileContainer.snp.makeConstraints {
            $0.top.equalTo(self.contentView.snp.top).offset(15)
            $0.left.equalTo(self.contentView.snp.left).offset(25)
            $0.right.equalTo(self.contentView.snp.right).offset(-25)
        }
        
        // MARK: TODO - 로그인의 여부에 따라서 프로필사진, 팔로워, 팔로잉 / "로그인이 필요합니다" 다르게 보이도록 분기처리
        setLoginProfileView()
    }
    
    func setLoginProfileView() {
        [self.profileImageView, self.followerLabel, self.followerCountLabel,
         self.followingLabel, self.followingCountLabel].forEach{ self.profileContainer.addSubview($0) }
        
        self.profileImageView.snp.makeConstraints {
            $0.top.equalTo(self.profileContainer.snp.top).offset(10)
            $0.left.equalTo(self.profileContainer.snp.left).offset(10)
            $0.bottom.equalTo(self.profileContainer.snp.bottom).offset(-10)
        }
        
        self.followerLabel.snp.makeConstraints {
            $0.top.equalTo(self.profileImageView.snp.top).offset(8)
            $0.centerX.equalTo(self.profileContainer.snp.centerX)
        }
        
        self.followerCountLabel.snp.makeConstraints {
            $0.bottom.equalTo(self.profileImageView.snp.bottom).offset(-8)
            $0.centerX.equalTo(self.profileContainer.snp.centerX)
        }
        
        self.followingLabel.snp.makeConstraints {
            $0.top.equalTo(self.profileImageView.snp.top).offset(8)
            $0.right.equalTo(self.profileContainer.snp.right).offset(-40)
        }
        
        self.followingCountLabel.snp.makeConstraints {
            $0.bottom.equalTo(self.profileImageView.snp.bottom).offset(-8)
            $0.centerX.equalTo(self.followingLabel.snp.centerX)
        }
    }
    
    func setNotLoginProfileView() {
        self.profileContainer.addSubview(self.notLoginLabel)
        
        self.notLoginLabel.snp.makeConstraints {
            $0.centerX.equalTo(self.profileContainer.snp.centerX)
            $0.centerY.equalTo(self.profileContainer.snp.centerY)
        }
    }
    
    func setUserInfoView() {
        [self.userInfoLabel, self.profileEditButton, self.userInfoContainer].forEach{ self.contentView.addSubview($0) }
        
        self.userInfoLabel.snp.makeConstraints {
            $0.top.equalTo(self.profileContainer.snp.bottom).offset(20)
            $0.left.equalTo(self.profileContainer.snp.left).offset(5)
        }
        
        self.profileEditButton.snp.makeConstraints {
            $0.centerY.equalTo(self.userInfoLabel.snp.centerY)
            $0.right.equalTo(self.profileContainer.snp.right).offset(-5)
        }
        
        self.userInfoContainer.snp.makeConstraints {
            $0.top.equalTo(self.userInfoLabel.snp.bottom).offset(8)
            $0.left.equalTo(self.userInfoLabel.snp.left)
            $0.right.equalTo(self.profileEditButton.snp.right)
        }
        
        [self.firstSeparator, self.secondSeparator, self.userNickNameLabel,
         self.userHeightLabel, self.userWeightLabel, self.userNickName,
         self.userHeight, self.userWeight].forEach{ self.userInfoContainer.addSubview($0) }
        
        self.firstSeparator.snp.makeConstraints {
            $0.top.equalTo(self.userInfoContainer.snp.top).offset(50)
            $0.left.equalTo(self.userInfoContainer.snp.left).offset(15)
            $0.right.equalTo(self.userInfoContainer.snp.right).offset(-15)
        }
        
        self.secondSeparator.snp.makeConstraints {
            $0.top.equalTo(self.firstSeparator.snp.top).offset(50)
            $0.left.equalTo(self.userInfoContainer.snp.left).offset(15)
            $0.right.equalTo(self.userInfoContainer.snp.right).offset(-15)
        }
        
        self.userNickNameLabel.snp.makeConstraints {
            $0.top.equalTo(self.userInfoContainer.snp.top).offset(15)
            $0.left.equalTo(self.userInfoContainer.snp.left).offset(10)
        }
        
        self.userHeightLabel.snp.makeConstraints {
            $0.centerY.equalTo(self.userInfoContainer.snp.centerY)
            $0.left.equalTo(self.userNickNameLabel.snp.left)
        }
        
        self.userWeightLabel.snp.makeConstraints {
            $0.top.equalTo(self.secondSeparator.snp.bottom).offset(15)
            $0.left.equalTo(self.userNickNameLabel.snp.left)
        }
        
        self.userNickName.snp.makeConstraints {
            $0.top.equalTo(self.userNickNameLabel.snp.top)
            $0.left.equalTo(self.userNickNameLabel.snp.right).offset(60)
        }
        
        self.userHeight.snp.makeConstraints {
            $0.top.equalTo(self.userHeightLabel.snp.top)
            $0.left.equalTo(self.userNickName.snp.left)
        }
        
        self.userWeight.snp.makeConstraints {
            $0.top.equalTo(self.userWeightLabel.snp.top)
            $0.left.equalTo(self.userNickName.snp.left)
        }
        
        self.profileEditButton.addAction(UIAction { [weak self] _ in
            guard let self = self, let user = service.combineUser else { return }
            let profileEditView = EditProfileInfoView(user: user)
            navigationController?.pushViewController(profileEditView, animated: true)
        }, for: .touchUpInside)
    }
    
    func setTotalRecordView() {
        [self.totalRecordLabel, self.totalRecordContainer].forEach{ self.contentView.addSubview($0) }
        
        totalRecordLabel.snp.makeConstraints {
            $0.top.equalTo(self.userInfoContainer.snp.bottom).offset(20)
            $0.left.equalTo(self.userInfoLabel.snp.left)
        }
        
        totalRecordContainer.snp.makeConstraints {
            $0.top.equalTo(self.totalRecordLabel.snp.bottom).offset(8)
            $0.left.equalTo(self.userInfoContainer.snp.left)
            $0.right.equalTo(self.userInfoContainer.snp.right)
        }
        
        [self.totalRunCount, self.totalRunCountSeparator, self.totalRunCountData,
         self.totalRunTime, self.totalRunTimeSeparator, self.totalRunTimeData,
         self.totalRunDistance, self.totalRunDistanceSeparator, self.totalRunDistanceData].forEach{ self.totalRecordContainer.addSubview($0) }
        
        self.totalRunCount.snp.makeConstraints {
            $0.top.equalTo(self.totalRecordContainer.snp.top).offset(20)
            $0.left.equalTo(self.totalRecordContainer.snp.left).offset(10)
        }
        
        self.totalRunCountSeparator.snp.makeConstraints {
            $0.top.equalTo(self.totalRunCount.snp.bottom).offset(8)
            $0.centerX.equalTo(self.totalRunCount.snp.centerX)
            $0.width.equalTo(20)
        }
        
        self.totalRunCountData.snp.makeConstraints {
            $0.top.equalTo(self.totalRunCountSeparator.snp.bottom).offset(8)
            $0.centerX.equalTo(self.totalRunCount.snp.centerX)
        }
        
        self.totalRunTime.snp.makeConstraints {
            $0.top.equalTo(self.totalRunCount.snp.top)
            $0.centerX.equalTo(self.totalRecordContainer.snp.centerX)
        }
        
        self.totalRunTimeSeparator.snp.makeConstraints {
            $0.top.equalTo(self.totalRunCountSeparator.snp.top)
            $0.centerX.equalTo(self.totalRecordContainer.snp.centerX)
            $0.width.equalTo(self.totalRunCountSeparator.snp.width)
        }
        
        self.totalRunTimeData.snp.makeConstraints {
            $0.top.equalTo(self.totalRunCountData.snp.top)
            $0.centerX.equalTo(self.totalRecordContainer.snp.centerX)
        }
        
        self.totalRunDistance.snp.makeConstraints {
            $0.top.equalTo(self.totalRunCount.snp.top)
            $0.right.equalTo(self.totalRecordContainer.snp.right).offset(-10)
        }
        
        self.totalRunDistanceSeparator.snp.makeConstraints {
            $0.top.equalTo(self.totalRunCountSeparator.snp.top)
            $0.centerX.equalTo(self.totalRunDistance.snp.centerX)
            $0.width.equalTo(20)
        }
        
        self.totalRunDistanceData.snp.makeConstraints {
            $0.top.equalTo(self.totalRunCountData.snp.top)
            $0.centerX.equalTo(self.totalRunDistance.snp.centerX)
        }
    }
    
    func setRecordByPeriodView() {
        [self.recordByPeriodLabel, self.recordByPeriodDetailButton, self.recordByPeriodPicker,
         self.dataLabel, self.graphCollectionView, self.pagingIndicator, self.selectedPeriodTotalRecordContainer].forEach{ self.contentView.addSubview($0) }
        
        self.recordByPeriodLabel.snp.makeConstraints {
            $0.top.equalTo(self.totalRecordContainer.snp.bottom).offset(20)
            $0.left.equalTo(self.totalRecordContainer.snp.left)
        }
        
        self.recordByPeriodDetailButton.snp.makeConstraints {
            $0.centerY.equalTo(self.recordByPeriodLabel.snp.centerY)
            $0.right.equalTo(self.profileEditButton.snp.right)
        }
        
        self.recordByPeriodPicker.snp.makeConstraints {
            $0.top.equalTo(self.recordByPeriodLabel.snp.bottom).offset(8)
            $0.left.equalTo(self.totalRecordContainer.snp.left)
            $0.right.equalTo(self.totalRecordContainer.snp.right)
        }
        
        self.dataLabel.snp.makeConstraints {
            $0.top.equalTo(self.recordByPeriodPicker.snp.bottom).offset(8)
            $0.left.equalTo(self.recordByPeriodPicker.snp.left)
        }
        
        self.graphCollectionView.snp.makeConstraints {
            $0.top.equalTo(self.dataLabel.snp.bottom).offset(8)
            $0.left.equalTo(self.recordByPeriodPicker.snp.left)
            $0.right.equalTo(self.recordByPeriodPicker.snp.right)
            $0.height.equalTo(400)
        }
        
        self.pagingIndicator.snp.makeConstraints {
            $0.top.equalTo(self.graphCollectionView.snp.bottom).offset(8)
            $0.centerX.equalTo(self.graphCollectionView.snp.centerX)
        }
        
        self.selectedPeriodTotalRecordContainer.snp.makeConstraints {
            $0.top.equalTo(self.pagingIndicator.snp.bottom).offset(8)
            $0.left.equalTo(self.graphCollectionView.snp.left)
            $0.right.equalTo(self.graphCollectionView.snp.right)
            $0.bottom.equalTo(self.contentView.snp.bottom).offset(-20)
        }
        
        [self.selectedPeriodTitle, self.selectedPeriodSeparator, self.selectedPeriodData].forEach{ self.selectedPeriodTotalRecordContainer.addSubview($0) }
        
        self.selectedPeriodTitle.snp.makeConstraints {
            $0.top.equalTo(self.selectedPeriodTotalRecordContainer.snp.top).offset(15)
            $0.centerX.equalTo(self.selectedPeriodTotalRecordContainer.snp.centerX)
        }
        
        self.selectedPeriodSeparator.snp.makeConstraints {
            $0.top.equalTo(self.selectedPeriodTitle.snp.bottom).offset(12)
            $0.centerX.equalTo(self.selectedPeriodTitle.snp.centerX)
            $0.width.equalTo(20)
        }
        
        self.selectedPeriodData.snp.makeConstraints {
            $0.top.equalTo(self.selectedPeriodSeparator.snp.bottom).offset(15)
            $0.centerX.equalTo(self.selectedPeriodTitle.snp.centerX)
            
            selectedPeriodData.text = "121.23\(selectedPeriodDataUnit)"
        }
    }
    
    func setUserData() {
        guard let user = service.signedUser else { return }
        if let imageUrl = user.user_image {
            self.profileImageView.kf.setImage(with: URL(string: imageUrl))
        }
        followerCountLabel.text = "\(user.user_follower.count)"
        followingCountLabel.text = "\(user.user_following.count)"
        userNickName.text = user.user_nickname
        userWeight.text = "\(user.user_weight)"
        if let height = user.user_tall {
            userHeight.text = "\(height)"
        } else {
            userHeight.text = "-"
        }
    }
    
    func setCombineData() {
        service.$combineUser
            .sink { [weak self] receivedUser in
                guard let self = self, let combineUser = receivedUser else { return }
                DispatchQueue.main.async {
                    self.userNickName.text = combineUser.user_nickname
                    self.userHeight.text = "\(combineUser.user_tall!)"
                    self.userWeight.text = "\(combineUser.user_weight)"
                }
            }
            .store(in: &cancellable)
    }
    
    @objc func settingButtonTapAction() {
        let settingView = SettingView()
        self.navigationController?.pushViewController(settingView, animated: true)
    }
    
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        // MARK: TODO - picker의 선택된 기간에 따라 그래프 변경 로직 추가
    }
}

extension MyPageView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return graphSectionCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GraphCollectionViewCell", for: indexPath) as? GraphCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.setGraph(type: .cadence)
        
        return cell
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let scrolledOffsetX = targetContentOffset.pointee.x + scrollView.contentInset.left
        let cellWidth = itemSize.width + itemSpacing
        let index = round(scrolledOffsetX / cellWidth)
        targetContentOffset.pointee = CGPoint(x: index * cellWidth - scrollView.contentInset.left, y: scrollView.contentInset.top)
        
        let indexInt = Int(index)
        var changeDataLabel: ShowingData = .cadence
        switch indexInt {
        case 0:
            changeDataLabel = .cadence
        case 1:
            changeDataLabel = .distance
        case 2:
            changeDataLabel = .speed
        case 3:
            changeDataLabel = .calories
        default:
            break
        }
        self.selectedPeriodDataUnit = changeDataLabel.unit
        
        DispatchQueue.main.async {
            self.dataLabel.text = changeDataLabel.rawValue
            self.selectedPeriodTitle.text = changeDataLabel.rawValue
            self.selectedPeriodData.text = "121.23\(self.selectedPeriodDataUnit)"
            for (index, subView) in self.pagingIndicator.subviews.enumerated() {
                guard let page = subView as? UIImageView else { continue }
                if index == indexInt {
                    page.tintColor = .primaryColor
                } else {
                    page.tintColor = .lightGray
                }
            }
            if let graphCell = self.graphCollectionView.cellForItem(at: IndexPath(row: indexInt, section: 0)) as? GraphCollectionViewCell {
                graphCell.lineChartDataSet?.label = changeDataLabel.rawValue
                graphCell.lineChartView.notifyDataSetChanged()
            }
        }
    }
    
    func setEventToProfileContainer() {
        let profileContainerTapEvent = UITapGestureRecognizer(target: self, action: #selector(toFollowerView))
        profileContainer.addGestureRecognizer(profileContainerTapEvent)
    }
    
    @objc func toFollowerView() {
        if service.signedUser != nil {
            let frientView = FollowManageView()
            self.navigationController?.pushViewController(frientView, animated: true)
        } else {
            self.showAlert(alertTitle: "알림", msg: "로그인이 필요한 기능입니다. 로그인 화면으로 이동할까요?", confirm: "예") {
                self.navigationController?.pushViewController(LoginView(), animated: true)
            }
        }
    }
}
