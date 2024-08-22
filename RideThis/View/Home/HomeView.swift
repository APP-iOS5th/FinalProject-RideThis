import UIKit
import SnapKit

class HomeView: RideThisViewController {
    private let viewModel = HomeViewModel()
    
    // MARK: 주간기록 안내 섹션 UI 요소들
    // 커스텀 타이틀
    private let customTitleLabel = RideThisLabel(fontType: .title, fontColor: .black, text: "Home")
    
    // sectionView: 흰색 배경
    private let weeklyRecordSectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    // 주간기록: 세컨 타이틀 라벨
    private let weeklyRecordTitleLabel: UILabel = {
        let label = RideThisLabel(fontType: .sectionTitle, fontColor: .black, text: "주간 기록")
        if let currentFont = label.font {
            label.font = UIFont.boldSystemFont(ofSize: currentFont.pointSize)
        }
        return label
    }()
    
    // 주간기록: 더보기 버튼
    private lazy var weeklyRecordMoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("더보기", for: .normal)
        button.setTitleColor(.primaryColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: FontCase.smallTitle.rawValue, weight: .regular)
        button.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // 주간기록: 데이터 배경 뷰
    private let weeklyRecordBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .primaryBackgroundColor
        view.layer.cornerRadius = 10
        return view
    }()
    
    // 주간기록: 헤더 뷰
    private lazy var weeklyRecordHeaderView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [weeklyRecordTitleLabel, weeklyRecordMoreButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    // 주간기록: 데이터
    private lazy var weeklyRecordDataView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            createRecordItemView(title: "달린 횟수", value: "\(viewModel.weeklyRecord.runCount)회"),
            createRecordItemView(title: "달린 시간", value: viewModel.weeklyRecord.runTime),
            createRecordItemView(title: "달린 거리", value: String(format: "%.2f Km", viewModel.weeklyRecord.runDistance))
        ])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 10
        return stackView
    }()
    
    // MARK: 라이딩 안내 섹션 UI 요소들
    private let letsRideSectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private lazy var letsRideTitleLabel: UILabel = {
        let userName = viewModel.userName
        let label = RideThisLabel(fontType: .sectionTitle, fontColor: .black, text: "\(userName)님, 라이딩 고고씽?")
        label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
        return label
    }()
    
    private let letsRideDescriptionLabel: UILabel = {
        let label = RideThisLabel(fontType: .defaultSize, fontColor: .gray, text: "바로 운동을 시작하시려면 라이딩 고고씽 버튼을 눌러주세요.\n운동을 마치면 운동하신 통계를 보여드릴게요.")
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var letsRideButton: RideThisButton = {
        let button = RideThisButton(buttonTitle: "라이딩 고고씽", height: 50)
        button.addTarget(self, action: #selector(letsRideButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: 날씨 안내 섹션 UI 요소들
    private let weatherSectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private lazy var weatherTitleLabel: UILabel = {
        let label = RideThisLabel(fontType: .sectionTitle, fontColor: .black, text: "라이딩하기 따악 좋은 날이고만!")
        label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        weeklyRecordSectionContentView()
        letsRideSectionContentView()
        weatherSectionContentView()
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
        
        let leftBarButtonItem = UIBarButtonItem(customView: customTitleLabel)
        navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    // MARK: weeklyRecord(wr) Section View
    private func weeklyRecordSectionContentView() {
        view.addSubview(weeklyRecordSectionView)
        weeklyRecordSectionView.snp.makeConstraints { wrSection in
            wrSection.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            wrSection.leading.trailing.equalToSuperview()
            wrSection.height.equalTo(200)
        }
        
        weeklyRecordSectionView.addSubview(weeklyRecordHeaderView)
        weeklyRecordHeaderView.snp.makeConstraints { wrHeader in
            wrHeader.top.equalTo(weeklyRecordSectionView).offset(20)
            wrHeader.leading.equalTo(weeklyRecordSectionView).offset(16)
            wrHeader.trailing.equalTo(weeklyRecordSectionView).offset(-16)
        }
        
        weeklyRecordSectionView.addSubview(weeklyRecordBackgroundView)
        weeklyRecordBackgroundView.snp.makeConstraints { wrBackground in
            wrBackground.top.equalTo(weeklyRecordHeaderView.snp.bottom).offset(10)
            wrBackground.leading.equalTo(weeklyRecordSectionView).offset(16)
            wrBackground.trailing.equalTo(weeklyRecordSectionView).offset(-16)
            wrBackground.height.equalTo(120)
        }
        
        weeklyRecordBackgroundView.addSubview(weeklyRecordDataView)
        weeklyRecordDataView.snp.makeConstraints { wrData in
            wrData.center.equalToSuperview()
            wrData.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    // MARK: letsRide(lr) Section View
    private func letsRideSectionContentView() {
        view.addSubview(letsRideSectionView)
        letsRideSectionView.snp.makeConstraints { lrSection in
            lrSection.top.equalTo(weeklyRecordSectionView.snp.bottom).offset(10)
            lrSection.leading.trailing.equalToSuperview()
            lrSection.height.equalTo(200)
        }
        
        letsRideSectionView.addSubview(letsRideTitleLabel)
        letsRideTitleLabel.snp.makeConstraints { lrTitleLabel in
            lrTitleLabel.top.equalToSuperview().offset(20)
            lrTitleLabel.leading.trailing.equalToSuperview().inset(16)
        }
        
        letsRideSectionView.addSubview(letsRideDescriptionLabel)
        letsRideDescriptionLabel.snp.makeConstraints { lrDescriptionLabel in
            lrDescriptionLabel.top.equalTo(letsRideTitleLabel.snp.bottom).offset(10)
            lrDescriptionLabel.leading.trailing.equalToSuperview().inset(16)
        }
        
        letsRideSectionView.addSubview(letsRideButton)
        letsRideButton.snp.makeConstraints { lrButton in
            lrButton.top.equalTo(letsRideDescriptionLabel.snp.bottom).offset(16)
            lrButton.leading.trailing.equalToSuperview().inset(16)
            lrButton.bottom.equalToSuperview().offset(-16)
        }
    }
    
    // MARK: weather(w) Section View
    private func weatherSectionContentView() {
        view.addSubview(weatherSectionView)
        weatherSectionView.snp.makeConstraints { wSection in
            wSection.top.equalTo(letsRideSectionView.snp.bottom).offset(10)
            wSection.leading.trailing.equalToSuperview()
            wSection.height.equalTo(230)
        }
        
        weatherSectionView.addSubview(weatherTitleLabel)
        weatherTitleLabel.snp.makeConstraints { wTitleLabel in
            wTitleLabel.top.equalToSuperview().offset(20)
            wTitleLabel.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    // MARK: weeklyRecord Data Set
    private func createRecordItemView(title: String, value: String) -> UIView {
        let containerView = UIView()
        
        let titleLabel = RideThisLabel(fontType: .defaultSize, fontColor: .black, text: title)
        titleLabel.textAlignment = .center
        
        let valueLabel = RideThisLabel(fontType: .profileFont, fontColor: .black, text: value)
        valueLabel.textAlignment = .center
        
        let weeklyRecordDataSetView = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        weeklyRecordDataSetView.axis = .vertical
        weeklyRecordDataSetView.alignment = .center
        weeklyRecordDataSetView.spacing = 20
        
        containerView.addSubview(weeklyRecordDataSetView)
        
        weeklyRecordDataSetView.snp.makeConstraints { wrDataSet in
            wrDataSet.center.equalToSuperview()
        }
        
        return containerView
    }
    
    // 더보기 버튼 누르면 일단 마이페이지로 이동
    @objc private func moreButtonTapped() {
        let myPageView = MyPageView()
        navigationController?.pushViewController(myPageView, animated: true)
    }
    
    // 라이딩 고고씽 버튼: 기록탭으로 전환
    // TODO: 탭바 이슈
    @objc private func letsRideButtonTapped() {
        let recordView = RecordView()
        navigationController?.pushViewController(recordView, animated: true)
        
        let recordTabIndex = 2
        tabBarController?.selectedIndex = recordTabIndex
    }
    
}

#Preview {
    UINavigationController(rootViewController: HomeView())
}
