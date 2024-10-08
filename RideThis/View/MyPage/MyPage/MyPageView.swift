import UIKit
import Kingfisher
import SnapKit
import FirebaseFirestore
import Combine

// 마이페이지 초기 화면
class MyPageView: RideThisViewController {
    
    var coordinator: MyPageCoordinator?
    lazy var followCoordinator = FollowManageCoordinator(navigationController: self.navigationController!, user: self.service.combineUser)
    
    // MARK: Data Components
    let service = UserService.shared
    var viewModel: MyPageViewModel
    private let firebaseService = FireBaseService()
    private var cancellable = Set<AnyCancellable>()
    private var followDelegate: UpdateUserDelegate?
    private var selectedDataType: RecordDataCase = .cadence
    private var selectedPeriod: RecordPeriodCase {
        get {
            switch self.recordByPeriodPicker.selectedSegmentIndex {
            case 0:
                return .oneWeek
            case 1:
                return .oneMonth
            case 2:
                return .threeMonths
            case 3:
                return .sixMonths
            default:
                return .oneWeek
            }
        }
    }
    
    // 커스텀 타이틀
    private let customTitleLabel = RideThisLabel(fontType: .subTitle, fontColor: .black, text: "마이페이지")
    
    init(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        imageView.contentMode = .scaleAspectFill
        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.layer.cornerRadius = 40
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    // MARK: TODO - 팔로워 / 팔로잉 숫자가 커질 때 잘 대비 해야함.
    private let followerLabel = RideThisLabel(fontType: .profileFont, text: "팔로워")
    private let followerCountLabel = RideThisLabel(fontType: .profileFont)
    private lazy var followerStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.addArrangedSubview(followerLabel)
        stack.addArrangedSubview(followerCountLabel)
        stack.distribution = .fillEqually
        stack.spacing = -10
        
        return stack
    }()
    private lazy var followerStackContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(followerStackView)
        followerStackView.snp.makeConstraints {
            $0.top.equalTo(container.snp.top)
            $0.left.equalTo(container.snp.left)
            $0.right.equalTo(container.snp.right)
            $0.bottom.equalTo(container.snp.bottom)
        }
        container.heightAnchor.constraint(equalToConstant: 100).isActive = true
        container.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        return container
    }()
    private let followingLabel = RideThisLabel(fontType: .profileFont, text: "팔로잉")
    private let followingCountLabel = RideThisLabel(fontType: .profileFont)
    private lazy var followingStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.addArrangedSubview(followingLabel)
        stack.addArrangedSubview(followingCountLabel)
        stack.distribution = .fillEqually
        stack.spacing = -10
        
        return stack
    }()
    private lazy var followingStackContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(followingStackView)
        followingStackView.snp.makeConstraints {
            $0.top.equalTo(container.snp.top)
            $0.left.equalTo(container.snp.left)
            $0.right.equalTo(container.snp.right)
            $0.bottom.equalTo(container.snp.bottom)
        }
        container.heightAnchor.constraint(equalToConstant: 100).isActive = true
        container.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        return container
    }()
    private lazy var totalFollowStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .center
        stack.distribution = .equalCentering
        stack.addArrangedSubview(profileImageView)
        stack.addArrangedSubview(followerStackContainer)
        stack.addArrangedSubview(followingStackContainer)
        
        return stack
    }()
    private let notLoginLabel = RideThisLabel(fontType: .recordInfoTitle, text: "로그인이 필요한 화면입니다.")
    private let loginButton = RideThisButton(buttonTitle: "로그인", height: 50)
    
    // MARK: 접속한 사용자 정보
    private let userInfoLabel = RideThisLabel(fontType: .profileFont, text: "정보")
    private lazy var profileEditButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("정보 수정", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
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
    private lazy var totalRunCountData = RideThisLabel(fontType: .classification)
    private let totalRunTime = RideThisLabel(fontColor: .recordTitleColor, text: "총 달린 시간")
    private let totalRunTimeSeparator = RideThisSeparator()
    private let totalRunTimeData = RideThisLabel(fontType: .classification)
    private let totalRunDistance = RideThisLabel(fontColor: .recordTitleColor, text: "총 달린 거리")
    private let totalRunDistanceSeparator = RideThisSeparator()
    private lazy var totalRunDistanceData = RideThisLabel(fontType: .classification)
    
    // MARK: Record By Period
    private let recordByPeriodLabel = RideThisLabel(fontType: .profileFont2, text: "기간별 평균 기록")
    private lazy var recordByPeriodDetailButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("자세히 보기", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        btn.contentVerticalAlignment = .top
        btn.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            
            self.coordinator?.showRecordListView()
        }, for: .touchUpInside)
        
        return btn
    }()
    private let periodOptions: [RecordPeriodCase] = RecordPeriodCase.allCases
    private lazy var recordByPeriodPicker: UISegmentedControl = {
        let picker = UISegmentedControl(items: self.periodOptions.map{ $0.rawValue })
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.selectedSegmentIndex = 0
        picker.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        
        return picker
    }()
    private let dataLabel = RideThisLabel(fontType: .profileFont2, text: "Cadence")
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
            let btn = UIButton()
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.setImage(UIImage(systemName: "circle.fill"), for: .normal)
            btn.widthAnchor.constraint(equalToConstant: 12).isActive = true
            btn.heightAnchor.constraint(equalToConstant: 12).isActive = true
            btn.tag = i
            
            if i == 0 {
                btn.tintColor = .primaryColor
            } else {
                btn.tintColor = .lightGray
            }
            
            btn.addAction(UIAction { [weak self] _ in
                guard let self = self else { return }
                
                self.graphCollectionView.scrollToItem(at: IndexPath(item: i, section: 0), at: .centeredHorizontally, animated: true)
                DispatchQueue.main.async {
                    self.reloadGraphCell(indexInt: i)
                }
            }, for: .touchUpInside)
            
            stack.addArrangedSubview(btn)
        }
        
        return stack
    }()
    private lazy var leftButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        btn.tintColor = .primaryColor
        btn.setTitleColor(.primaryColor, for: .normal)
        btn.setTitleColor(.lightGray, for: .disabled)
        btn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        btn.isEnabled = self.selectedDataType != .cadence
        btn.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            let cellWidth = itemSize.width + itemSpacing
            let offsetX = graphCollectionView.contentOffset.x + graphCollectionView.contentInset.left
            let index = Int(round(offsetX / cellWidth))
            
            self.graphCollectionView.scrollToItem(at: IndexPath(item: index - 1, section: 0), at: .centeredHorizontally, animated: true)
            DispatchQueue.main.async {
                self.reloadGraphCell(indexInt: index - 1)
            }
        }, for: .touchUpInside)
        
        return btn
    }()
    private lazy var rightButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        btn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        btn.tintColor = .primaryColor
        btn.setTitleColor(.primaryColor, for: .normal)
        btn.setTitleColor(.lightGray, for: .disabled)
        btn.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            let cellWidth = itemSize.width + itemSpacing
            let offsetX = graphCollectionView.contentOffset.x + graphCollectionView.contentInset.left
            let index = Int(round(offsetX / cellWidth))
            
            self.graphCollectionView.scrollToItem(at: IndexPath(item: index + 1, section: 0), at: .centeredHorizontally, animated: true)
            DispatchQueue.main.async {
                self.reloadGraphCell(indexInt: index + 1)
            }
        }, for: .touchUpInside)
        
        return btn
    }()
    private let selectedPeriodTotalRecordContainer = RideThisContainer(height: 75)
//    private let selectedPeriodTitle = RideThisLabel(fontType: .recordInfoTitle, text: "Cadence")
//    private let selectedPeriodSeparator = RideThisSeparator()
    private let selectedPeriodData = RideThisLabel(fontType: .title)
    private var selectedPeriodDataUnit = RecordDataCase.cadence.unit
    
    // MARK: Data for UI
    lazy var itemSize = CGSize(width: self.view.frame.width - 65, height: 400)
    let graphSectionCount = 4
    let itemSpacing = 15.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTotalGrid()
        setCombineData()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task {
            guard let signedUser = UserService.shared.combineUser else { return }
            if case .user(let receivedUser) = try await firebaseService.fetchUser(at: signedUser.user_id, userType: true) {
                guard let user = receivedUser else { return }
                
                followerCountLabel.text = "\(user.user_follower.count)"
                followingCountLabel.text = "\(user.user_following.count)"
                userNickName.text = user.user_nickname
                userWeight.text = "\(user.user_weight)"
                userHeight.text = user.tallStr
                
                followCoordinator.updateUser(user: user)
            }
        }
    }
    
    // MARK: Navigation Bar
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.isTranslucent = false
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        // 커스텀 타이틀 레이블을 왼쪽 바 버튼 아이템으로 설정
        let leftBarButtonItem = UIBarButtonItem(customView: customTitleLabel)
        navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    func setTotalGrid() {
        setUIComponents()
        setUserData()
//        setCombineData()
    }
    
    func setUIComponents() {
        for subview in view.subviews {
            subview.removeFromSuperview()
        }
        if service.combineUser == nil {
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
            $0.centerY.equalTo(view.snp.centerY).offset(-25)
            $0.centerX.equalTo(view.snp.centerX)
        }
        
        loginButton.snp.makeConstraints {
            $0.top.equalTo(notLoginLabel.snp.bottom).offset(25)
            $0.left.equalTo(notLoginLabel.snp.left)
            $0.right.equalTo(notLoginLabel.snp.right)
        }
        
        loginButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            
            let loginCoordinator = LoginCoordinator(navigationController: self.navigationController!, childCoordinators: [], prevViewCase: .myPage, backBtnTitle: "마이페이지")
            
            loginCoordinator.start()
        }, for: .touchUpInside)
    }
    
    func setNavigationComponents() {
        let settingButton = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: #selector(settingButtonTapAction))
        settingButton.tintColor = .label
        self.navigationItem.rightBarButtonItem = settingButton
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
        self.profileContainer.addSubview(totalFollowStackView)
        
        totalFollowStackView.snp.makeConstraints {
            $0.top.equalTo(profileContainer.snp.top)
            $0.left.equalTo(profileContainer.snp.left).offset(30)
            $0.right.equalTo(profileContainer.snp.right).offset(-30)
            $0.bottom.equalTo(profileContainer.snp.bottom)
        }
    }
    
    func setUserInfoView() {
        [self.userInfoLabel, self.profileEditButton, self.userInfoContainer].forEach{ self.contentView.addSubview($0) }
        
        self.userInfoLabel.snp.makeConstraints {
            $0.top.equalTo(self.profileContainer.snp.bottom).offset(30)
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
            self.profileEditButton.isEnabled = false
            
            self.coordinator?.moveToEditView(user: user)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.profileEditButton.isEnabled = true
            }
        }, for: .touchUpInside)
    }
    
    func setTotalRecordView() {
        [self.totalRecordLabel, self.totalRecordContainer].forEach{ self.contentView.addSubview($0) }
        
        totalRecordLabel.snp.makeConstraints {
            $0.top.equalTo(self.userInfoContainer.snp.bottom).offset(30)
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
            $0.width.equalTo(35)
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
            $0.width.equalTo(35)
        }
        
        self.totalRunDistanceData.snp.makeConstraints {
            $0.top.equalTo(self.totalRunCountData.snp.top)
            $0.centerX.equalTo(self.totalRunDistance.snp.centerX)
        }
    }
    
    func setRecordByPeriodView() {
        [self.recordByPeriodLabel, self.recordByPeriodDetailButton, self.recordByPeriodPicker, self.leftButton, self.rightButton,
         self.dataLabel, self.graphCollectionView, self.pagingIndicator, self.selectedPeriodTotalRecordContainer].forEach{ self.contentView.addSubview($0) }
        
        self.dataLabel.snp.makeConstraints {
            $0.top.equalTo(self.totalRecordContainer.snp.bottom).offset(30)
            $0.left.equalTo(self.totalRecordContainer.snp.left)
        }
        
        self.recordByPeriodLabel.snp.makeConstraints {
            $0.top.equalTo(self.dataLabel.snp.top)
            $0.left.equalTo(self.dataLabel.snp.right).offset(5)
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
        
        self.graphCollectionView.snp.makeConstraints {
            $0.top.equalTo(self.recordByPeriodPicker.snp.bottom).offset(15)
            $0.left.equalTo(self.recordByPeriodPicker.snp.left)
            $0.right.equalTo(self.recordByPeriodPicker.snp.right)
            $0.height.equalTo(400)
        }

        self.leftButton.snp.makeConstraints {
            $0.centerY.equalTo(graphCollectionView.snp.centerY)
            $0.right.equalTo(graphCollectionView.snp.left).offset(-5)
        }
        
        self.rightButton.snp.makeConstraints {
            $0.centerY.equalTo(graphCollectionView.snp.centerY)
            $0.left.equalTo(graphCollectionView.snp.right).offset(5)
        }
        
        self.pagingIndicator.snp.makeConstraints {
            $0.top.equalTo(self.graphCollectionView.snp.bottom).offset(20)
            $0.centerX.equalTo(self.graphCollectionView.snp.centerX)
        }
        
        self.selectedPeriodTotalRecordContainer.snp.makeConstraints {
            $0.top.equalTo(self.pagingIndicator.snp.bottom).offset(20)
            $0.left.equalTo(self.graphCollectionView.snp.left)
            $0.right.equalTo(self.graphCollectionView.snp.right)
            $0.bottom.equalTo(self.contentView.snp.bottom).offset(-20)
        }
        
        [self.selectedPeriodData].forEach{ self.selectedPeriodTotalRecordContainer.addSubview($0) }
        

        
        self.selectedPeriodData.snp.makeConstraints {
            $0.centerX.equalTo(self.selectedPeriodTotalRecordContainer.snp.centerX)
            $0.centerY.equalTo(self.selectedPeriodTotalRecordContainer.snp.centerY)
        }
    }
    
    // MARK: 애플로그인으로 접속한 회원을 Firebase에서 조회해 각 Label에 뿌려줌
    func setUserData() {
        guard let user = service.combineUser else { return }
        if let imageUrl = user.user_image {
            if imageUrl.isEmpty {
                self.profileImageView.image = UIImage(named: "bokdonge")
            } else {
                self.profileImageView.kf.setImage(with: URL(string: imageUrl))
            }
        }
        followerCountLabel.text = "\(user.user_follower.count)"
        followingCountLabel.text = "\(user.user_following.count)"
        userNickName.text = user.user_nickname
        userWeight.text = "\(user.user_weight)"
        userHeight.text = user.tallStr
        
        Task {
            await viewModel.getRecords(userId: user.user_id)
        }
    }
    
    // MARK: 회원정보 수정 및 팔로우 등의 이벤트를 처리 후 접속한 사용자의 정보가 업데이트 되었을 때 UI동적으로 처리
    func setCombineData() {
        service.$signedUser
            .sink { [weak self] receivedUser in
                guard let self = self, let combineUser = receivedUser else { return }
                DispatchQueue.main.async {
                    self.setTotalGrid()
                    if let imageUrl = combineUser.user_image {
                        if imageUrl.isEmpty {
                            self.profileImageView.image = UIImage(named: "bokdonge")
                        } else {
                            self.profileImageView.kf.setImage(with: URL(string: imageUrl))
                        }
                    }
                    self.followerCountLabel.text = "\(combineUser.user_follower.count)"
                    self.followingCountLabel.text = "\(combineUser.user_following.count)"
                    self.userNickName.text = combineUser.user_nickname
                    self.userWeight.text = "\(combineUser.user_weight)"
                    self.userHeight.text = combineUser.tallStr
                }
                followCoordinator.updateUser(user: combineUser)
            }
            .store(in: &cancellable)
        
        viewModel.$recordsData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] records in
                guard let self = self else { return }
                self.graphCollectionView.reloadData()
                
                let count = records.count
                var totalSeconds: Int = 0
                var totalDistance: Double = 0

                // MARK: TODO - 모든 기록에서 계산을 하는게 아닌 firebase에 총 합산 데이터 관리하는 컬렉션으로 관리하도록 변경
                for record in records {
                    totalDistance += record.record_distance
                    if let endTime = record.record_end_time, let startTime = record.record_start_time {
                        totalSeconds += viewModel.getRecordTimeDiff(endDate: endTime, startDate: startTime)
                    }
                }
                
                self.totalRunCountData.text = "\(count)회"
                self.totalRunTimeData.text = totalSeconds.secondsToRecordTime
                self.totalRunDistanceData.text = "\(totalDistance.overThousandStr) km"
            }
            .store(in: &cancellable)
        
        viewModel.$cadenceAvg
            .receive(on: DispatchQueue.main)
            .sink { [weak self] avg in
                guard let self = self else { return }
                
                self.selectedPeriodData.text = "\(avg)RPM"
            }
            .store(in: &cancellable)
        
        viewModel.$distanceAvg
            .receive(on: DispatchQueue.main)
            .sink { [weak self] avg in
                guard let self = self else { return }
                
                self.selectedPeriodData.text = "\(avg)km"
            }
            .store(in: &cancellable)
        
        viewModel.$speedAvg
            .receive(on: DispatchQueue.main)
            .sink { [weak self] avg in
                guard let self = self else { return }
                
                self.selectedPeriodData.text = "\(avg)km/h"
            }
            .store(in: &cancellable)
        
        viewModel.$caloriesAvg
            .receive(on: DispatchQueue.main)
            .sink { [weak self] avg in
                guard let self = self else { return }
                
                self.selectedPeriodData.text = "\(avg)Kcal"
            }
            .store(in: &cancellable)
    }
    
    @objc func settingButtonTapAction() {
        let settingCoordinator = SettingCoordinator(navigationController: self.navigationController!)
        settingCoordinator.start()
    }
    
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        graphCollectionView.reloadData()
    }
}

// MARK: 케이던스, 거리, 속도, 칼로리 그래프를 페이징으로 보여주기 위한 UICollectionView delegate들
extension MyPageView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return graphSectionCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GraphCollectionViewCell", for: indexPath) as? GraphCollectionViewCell else {
            return UICollectionViewCell()
        }
       
        let periodRecords = viewModel.getRecordsBy(period: self.selectedPeriod, dataCase: self.selectedDataType)
        cell.setGraph(type: selectedDataType, records: periodRecords, period: self.selectedPeriod)
        
        return cell
    }
    
    // MARK: CollectionViewFolowLayout을 좌우로 스와이프 했을 때 event
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let scrolledOffsetX = targetContentOffset.pointee.x + scrollView.contentInset.left
        let cellWidth = itemSize.width + itemSpacing
        let index = round(scrolledOffsetX / cellWidth)
        targetContentOffset.pointee = CGPoint(x: index * cellWidth - scrollView.contentInset.left, y: scrollView.contentInset.top)
        
        let indexInt = Int(index)
        
        DispatchQueue.main.async {
            self.selectedPeriodDataUnit = self.selectedDataType.unit
            self.reloadGraphCell(indexInt: indexInt)
        }
    }
    
    // MARK: 프로필 Container를 선택했을 때 팔로우 관리 페이지로 이동하는 event등록
    func setEventToProfileContainer() {
        let followerTapEvent = UITapGestureRecognizer(target: self, action: #selector(toFollowerView))
        let followingTapEvent = UITapGestureRecognizer(target: self, action: #selector(toFollowerView))
        followerStackView.addGestureRecognizer(followerTapEvent)
        followingStackView.addGestureRecognizer(followingTapEvent)
    }
    
    // MARK: 그래프 cell이동 후 UI업데이트
    func reloadGraphCell(indexInt: Int) {
        switch indexInt {
        case 0:
            selectedDataType = .cadence
        case 1:
            selectedDataType = .distance
        case 2:
            selectedDataType = .speed
        case 3:
            selectedDataType = .calories
        default:
            break
        }
        self.dataLabel.text = self.selectedDataType.rawValue
//        self.selectedPeriodTitle.text = self.selectedDataType.rawValue
        self.leftButton.isEnabled = self.selectedDataType != .cadence
        self.rightButton.isEnabled = self.selectedDataType != .calories
        
        for (index, subView) in self.pagingIndicator.subviews.enumerated() {
            guard let page = subView as? UIButton else { continue }
            if index == indexInt {
                page.tintColor = .primaryColor
            } else {
                page.tintColor = .lightGray
            }
        }
        if let graphCell = self.graphCollectionView.cellForItem(at: IndexPath(row: indexInt, section: 0)) as? GraphCollectionViewCell {
            graphCell.setGraph(type: self.selectedDataType,
                               records: self.viewModel.getRecordsBy(period: self.selectedPeriod, dataCase: self.selectedDataType),
                               period: self.selectedPeriod)
            graphCell.lineChartDataSet?.label = nil
            graphCell.lineChartView.notifyDataSetChanged()
        }
    }
    
    // MARK: 프로필 Container를 선택했을 때 팔로우 관리 페이지로 이동
    @objc func toFollowerView() {
        if let _ = service.combineUser {
            followCoordinator.start()
        } else {
            self.showAlert(alertTitle: "알림", msg: "로그인이 필요한 기능입니다. 로그인 화면으로 이동할까요?", confirm: "예") {
                let loginCoordinator = LoginCoordinator(navigationController: self.navigationController!, childCoordinators: [], prevViewCase: .myPage, backBtnTitle: "마이페이지")
                loginCoordinator.start()
            }
        }
    }
}

// MARK: 프로필 사진을 편집했을 때 서버에서 저장 후 프로필의 이미지를 갱신할 때 시간이 걸려서 UI를 먼저 업데이트하고 서버작업은 뒤에서 하도록 하기 위한 delegate
extension MyPageView: ProfileImageUpdateDelegate {
    func imageUpdate(image: UIImage) {
        DispatchQueue.main.async {
            self.profileImageView.image = image
        }
    }
}
