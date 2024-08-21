import UIKit
import SnapKit

class HomeView: RideThisViewController {
    private let viewModel = HomeViewModel()
    
    // 커스텀 타이틀
    private let customTitleLabel = RideThisLabel(fontType: .title, fontColor: .black, text: "Home")
    
    // sectionView: 흰색 배경
    private let sectionView: UIView = {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        weeklyRecordSectionView()
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
    
    // MARK: weeklyRecord Section View
    private func weeklyRecordSectionView() {
        view.addSubview(sectionView)
        sectionView.snp.makeConstraints { section in
            section.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            section.leading.trailing.equalToSuperview()
            section.height.equalTo(200)
        }
        
        sectionView.addSubview(weeklyRecordHeaderView)
        sectionView.addSubview(weeklyRecordBackgroundView)
        
        weeklyRecordHeaderView.snp.makeConstraints { wrHeader in
            wrHeader.top.equalTo(sectionView).offset(20)
            wrHeader.leading.equalTo(sectionView).offset(16)
            wrHeader.trailing.equalTo(sectionView).offset(-16)
        }
        
        weeklyRecordBackgroundView.snp.makeConstraints { wrBackground in
            wrBackground.top.equalTo(weeklyRecordHeaderView.snp.bottom).offset(10)
            wrBackground.leading.equalTo(sectionView).offset(16)
            wrBackground.trailing.equalTo(sectionView).offset(-16)
            wrBackground.height.equalTo(120)
        }
        
        weeklyRecordBackgroundView.addSubview(weeklyRecordDataView)
        weeklyRecordDataView.snp.makeConstraints { wrData in
            wrData.center.equalToSuperview()
            wrData.leading.trailing.equalToSuperview().inset(16)
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
    
}

#Preview {
    UINavigationController(rootViewController: HomeView())
}
