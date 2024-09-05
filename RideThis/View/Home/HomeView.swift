import UIKit
import WeatherKit
import SnapKit
import Combine

class HomeView: RideThisViewController {
    // MARK: - Properties
    var coordinator: HomeCoordinator?
    
    let viewModel: HomeViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    // MARK: - Custom Title
    private let customTitleLabel = RideThisLabel(fontType: .title, fontColor: .black, text: "Home")
    
    // MARK: - Weekly Record Section
    private let weeklyRecordSectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    /// 주간기록: 세컨 타이틀 라벨
    private let weeklyRecordTitleLabel: UILabel = {
        let label = RideThisLabel(fontType: .sectionTitle, fontColor: .black, text: "주간 기록")
        if let currentFont = label.font {
            label.font = UIFont.boldSystemFont(ofSize: currentFont.pointSize)
        }
        return label
    }()
    
    /// 주간기록: 더보기 버튼
    private lazy var weeklyRecordMoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("더보기", for: .normal)
        button.setTitleColor(.primaryColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: FontCase.smallTitle.rawValue, weight: .regular)
        button.addAction(UIAction { [weak self] _ in
            self?.coordinator?.showRecordListView()
        }, for: .touchUpInside)
        return button
    }()
    
    /// 주간기록: 데이터 배경 뷰
    private let weeklyRecordBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .primaryBackgroundColor
        view.layer.cornerRadius = 10
        return view
    }()
    
    /// 주간기록: 헤더 뷰
    private lazy var weeklyRecordHeaderView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [weeklyRecordTitleLabel, weeklyRecordMoreButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    /// 주간기록: 데이터
    private lazy var weeklyRecordDataView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 10
        return stackView
    }()
    
    // MARK: - Let's Ride Section
    private let letsRideSectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private lazy var letsRideTitleLabel: UILabel = {
        let label = RideThisLabel(fontType: .sectionTitle, fontColor: .black, text: "")
        label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
        return label
    }()
    
    private let letsRideDescriptionLabel: UILabel = {
        let label = RideThisLabel(fontType: .defaultSize, fontColor: .gray, text: "바로 운동을 시작하시려면 라이딩 고고씽 버튼을 눌러주세요.\n운동을 마치면 운동하신 통계를 보여드릴게요.")
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var letsRideButton: RideThisButton = {
        let button = RideThisButton(buttonTitle: "Let's RideThis", height: 50)
        button.addAction(UIAction { [weak self] _ in
            self?.coordinator?.showRecordView()
        }, for: .touchUpInside)
        return button
    }()
    
    // MARK: - Weather Section
    private let weatherSectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private lazy var weatherTitleLabel: UILabel = {
        let label = RideThisLabel(fontType: .sectionTitle, fontColor: .black, text: "날씨 정보")
        label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
        
        return label
    }()
    
    private let weatherContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.backgroundColor = UIColor(red: 12/255, green: 79/255, blue: 146/255, alpha: 1)
        view.layer.masksToBounds = true
        
        return view
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.text = "우리집"
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let currentTemp: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 45, weight: .semibold)
        label.text = "76"
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let weatherSymbol: UIImageView = {
        let image = UIImageView(image: UIImage(systemName: "hare.fill"))
        image.tintColor = .white
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        
        return image
    }()
    
    private let weatherConditionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.text = "Sunny"
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let averageTempLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.text = "h:88 L:57"
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let weatherHStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }()
    
    // MARK: - Initialization
    init(viewModel: HomeViewModel = HomeViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupScrollView()
        setupContentView()
        setupBindings()
        
        viewModel.fetchUserData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refreshUserData()
        
        if let combineUser = UserService.shared.combineUser {
            Task {
                let alarmCount = await viewModel.getAlarmCount(userId: combineUser.user_id)
                
                let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: alarmCount > 0 ? "bell.badge" : "bell"), style: .done, target: self, action: #selector(moveToAlarmView))
                rightBarButtonItem.tintColor = .primaryColor
                navigationItem.rightBarButtonItem = rightBarButtonItem
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyGradientToWeatherContainer()
    }
    
    // MARK: - Setup Methods
    
    /// 메인 콘텐츠를 위한 스크롤 뷰 설정
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    /// 스크롤 뷰 내의 콘텐츠 뷰 설정
    private func setupContentView() {
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { contentView in
            contentView.edges.equalTo(scrollView)
            contentView.width.equalTo(scrollView)
        }
        
        weeklyRecordSectionContentView()
        letsRideSectionContentView()
        weatherSectionContentView()
        
        contentView.snp.makeConstraints { contentView in
            contentView.bottom.equalTo(weatherSectionView.snp.bottom).offset(20)
        }
    }
    
    /// NavigationBar 설정
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
    
    @objc func moveToAlarmView() {
        let alarmCoordinator = AlarmCoordinator(navigationController: self.navigationController!, childCoordinators: [])
        alarmCoordinator.start()
    }
    
    /// 주간 기록 섹션 콘텐츠 뷰 설정
    private func weeklyRecordSectionContentView() {
        contentView.addSubview(weeklyRecordSectionView)
        weeklyRecordSectionView.snp.makeConstraints { wrSection in
            wrSection.top.equalTo(contentView.snp.top).offset(10)
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
    
    /// "라이딩 고고씽" 섹션 콘텐츠 뷰 설정
    private func letsRideSectionContentView() {
        contentView.addSubview(letsRideSectionView)
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
    
    /// 날씨 섹션 콘텐츠 뷰 설정
    private func weatherSectionContentView() {
        setupWeatherUI()
        
        contentView.addSubview(weatherSectionView)
        weatherSectionView.snp.makeConstraints { wSection in
            wSection.top.equalTo(letsRideSectionView.snp.bottom).offset(10)
            wSection.leading.trailing.equalToSuperview()
            wSection.height.equalTo(238)
        }
        
        weatherSectionView.addSubview(weatherTitleLabel)
        weatherTitleLabel.snp.makeConstraints { wTitleLabel in
            wTitleLabel.top.equalToSuperview().offset(20)
            wTitleLabel.leading.trailing.equalToSuperview().inset(16)
        }
        
        weatherSectionView.addSubview(weatherContainer)
        weatherContainer.snp.makeConstraints { con in
            con.top.equalTo(weatherTitleLabel.snp.bottom).offset(15)
            con.left.equalTo(weatherSectionView.snp.left).offset(20)
            con.right.equalTo(weatherSectionView.snp.right).offset(-20)
            con.height.equalTo(160)
        }
        
        weatherContainer.addSubview(locationLabel)
        weatherContainer.addSubview(currentTemp)
        weatherContainer.addSubview(weatherSymbol)
        weatherContainer.addSubview(weatherConditionLabel)
        weatherContainer.addSubview(averageTempLabel)
        weatherContainer.addSubview(weatherHStackView)
        
        locationLabel.snp.makeConstraints { label in
            label.top.equalTo(weatherContainer.snp.top).offset(15)
            label.left.equalTo(weatherContainer.snp.left).offset(15)
        }
        currentTemp.snp.makeConstraints { temp in
            temp.top.equalTo(locationLabel.snp.bottom)
            temp.left.equalTo(weatherContainer.snp.left).offset(15)
        }
        weatherSymbol.snp.makeConstraints { symbol in
            symbol.top.equalTo(weatherContainer.snp.top).offset(15)
            symbol.right.equalTo(weatherContainer.snp.right).offset(-15)
        }
        weatherConditionLabel.snp.makeConstraints { label in
            label.top.equalTo(weatherSymbol.snp.bottom).offset(5)
            label.right.equalTo(weatherContainer.snp.right).offset(-15)
        }
        averageTempLabel.snp.makeConstraints { label in
            label.top.equalTo(weatherConditionLabel.snp.bottom).offset(5)
            label.right.equalTo(weatherContainer.snp.right).offset(-15)
        }
        weatherHStackView.snp.makeConstraints { con in
            con.bottom.equalTo(weatherContainer.snp.bottom).offset(-5)
            con.left.equalTo(weatherContainer.snp.left).offset(15)
            con.right.equalTo(weatherContainer.snp.right).offset(-15)
        }
    }
    
    /// 날씨 UI 컴포넌트와 바인딩 설정
    private func setupWeatherUI() {
        // 위치 이름 바인딩
        self.viewModel.$locationName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                self?.locationLabel.text = "\(location)"
            }
            .store(in: &cancellables)
        
        // 현재 날씨 바인딩
        self.viewModel.$currentWeather
            .receive(on: DispatchQueue.main)
            .sink { [weak self] weather in
                self?.currentTemp.text = "\(weather?.currentWeather.temperature.formatted() ?? "")"
                self?.weatherSymbol.image = UIImage(systemName: "\(weather?.currentWeather.symbolName ?? "")")
                self?.weatherConditionLabel.text = "\(weather?.currentWeather.condition.description ?? "")"
                
                if let todayForecast = weather?.dailyForecast.forecast.first(where: {
                    Calendar.current.isDate($0.date, inSameDayAs: Date())
                }) {
                    let highTemperature = Int(todayForecast.highTemperature.value)
                    let lowTemperature = Int(todayForecast.lowTemperature.value)
                    self?.averageTempLabel.text = "H:\(highTemperature)° L:\(lowTemperature)°"
                } else {
                    self?.averageTempLabel.text = ""
                }
            }
            .store(in: &cancellables)
        
        // 시간별 예보 바인딩
        self.viewModel.$hourlyForecast
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hourlyForecast in
                guard let self = self else { return }
                
                self.weatherHStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                
                let calendar = Calendar.current
                let now = Date()
                
                for i in 1...6 {
                    if let forecast = hourlyForecast.first(where: {
                        calendar.isDate($0.date, inSameDayAs: calendar.date(byAdding: .hour, value: i, to: now)!)
                    }) {
                        let weatherVStackView = self.createWeatherVStackView(forecast: forecast, hourOffset: i)
                        self.weatherHStackView.addArrangedSubview(weatherVStackView)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    /// 시간별 날씨 예보를 위한 수직 스택 뷰 생성
    /// - Parameters:
    ///   - forecast: 시간별 날씨 예보
    ///   - hourOffset: 현재 시간으로부터의 시간 오프셋
    /// - Returns: 시간별 예보에 맞게 구성된 UIStackView
    private func createWeatherVStackView(forecast: HourWeather, hourOffset: Int) -> UIStackView {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "ha"
        
        let weatherTimeLabel = UILabel()
        weatherTimeLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        weatherTimeLabel.textColor = .white
        weatherTimeLabel.textAlignment = .center
        weatherTimeLabel.text = timeFormatter.string(from: Calendar.current.date(byAdding: .hour, value: hourOffset, to: Date())!)
        
        let weatherTimeSymbol = UIImageView(image: UIImage(systemName: forecast.symbolName))
        weatherTimeSymbol.tintColor = .white
        weatherTimeSymbol.contentMode = .scaleAspectFit
        
        let weatherTimeTempLabel = UILabel()
        weatherTimeTempLabel.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        weatherTimeTempLabel.textColor = .white
        weatherTimeTempLabel.textAlignment = .center
        weatherTimeTempLabel.text = "\(Int(forecast.temperature.value))°"
        
        let weatherVStackView = UIStackView(arrangedSubviews: [weatherTimeLabel, weatherTimeSymbol, weatherTimeTempLabel])
        weatherVStackView.axis = .vertical
        weatherVStackView.alignment = .center
        weatherVStackView.spacing = 5
        
        return weatherVStackView
    }
    
    /// 단일 기록 항목을 표시하는 뷰 생성
    /// - Parameters:
    ///   - title: 기록 항목의 제목
    ///   - value: 기록 항목의 값
    /// - Returns: 기록 항목에 맞게 구성된 UIView
    private func createRecordItemView(title: String, value: String) -> UIView {
        let containerView = UIView()
        
        let titleLabel = RideThisLabel(fontType: .defaultSize, fontColor: .black, text: title)
        titleLabel.textAlignment = .center
        
        let valueLabel = RideThisLabel(fontType: .profileFont, fontColor: .black, text: value)
        valueLabel.textAlignment = .center
        
        let separator = RideThisSeparator()
        separator.snp.makeConstraints { separator in
            separator.width.equalTo(35)
            separator.height.equalTo(3)
        }
        
        let weeklyRecordDataSetView = UIStackView(arrangedSubviews: [titleLabel, separator, valueLabel])
        weeklyRecordDataSetView.axis = .vertical
        weeklyRecordDataSetView.alignment = .center
        weeklyRecordDataSetView.spacing = 10
        
        containerView.addSubview(weeklyRecordDataSetView)
        
        weeklyRecordDataSetView.snp.makeConstraints { wrDataSet in
            wrDataSet.edges.equalToSuperview()
        }
        
        return containerView
    }
    
    /// 뷰 모델의 데이터 바인딩 설정
    private func setupBindings() {
        viewModel.$model
            .receive(on: DispatchQueue.main)
            .sink { [weak self] model in
                guard let self = self else { return }
                
                if !model.userName.isEmpty {
                    viewModel.fetchAddFCM()
                }
                
                self.updateUI(with: model)
            }
            .store(in: &cancellables)
    }
    
    /// 전달받은 모델 데이터를 사용하여 UI 업데이트
    /// - Parameter model: 화면에 표시할 데이터를 담고 있는 HomeModel
    private func updateUI(with model: HomeModel) {
        weeklyRecordDataView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        weeklyRecordDataView.addArrangedSubview(createRecordItemView(title: "달린 횟수", value: "\(model.weeklyRecord.runCount)회"))
        weeklyRecordDataView.addArrangedSubview(createRecordItemView(title: "달린 시간", value: model.weeklyRecord.runTime))
        weeklyRecordDataView.addArrangedSubview(createRecordItemView(title: "달린 거리", value: String(format: "%.2f Km", model.weeklyRecord.runDistance)))
        
        let userNickName = model.userName.isEmpty ? "비회원" : model.userName
        letsRideTitleLabel.text = "\(userNickName)님, Let's RideThis?"
    }
    
    /// 날씨 컨테이너 뷰에 그라디언트 적용
    private func applyGradientToWeatherContainer() {
        weatherContainer.setGradient(color1: UIColor(red: 12/255, green: 79/255, blue: 146/255, alpha: 1),
                                     color2: UIColor(red: 77/255, green: 143/255, blue: 209/255, alpha: 1))
    }
}
