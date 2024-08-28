import UIKit
import WeatherKit
import SnapKit
import Combine

class HomeView: RideThisViewController {
    
    var coordinator: HomeCoordinator?
    
    private let viewModel: HomeViewModel
    
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: HomeViewModel = HomeViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        let stackView = UIStackView()
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
    
    // MARK: Weather
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        weeklyRecordSectionContentView()
        letsRideSectionContentView()
        weatherSectionContentView()
        setupBindings()
    }
    
    // MARK: WeathrContainer 그라데이션
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        weatherContainer.setGradient(color1: UIColor(red: 12/255, green: 79/255, blue: 146/255, alpha: 1),
                                     color2: UIColor(red: 77/255, green: 143/255, blue: 209/255, alpha: 1))
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
        
        setupWeatherUI()
        
        view.addSubview(weatherSectionView)
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
    
    // MARK: Setup Weather UI
    private func setupWeatherUI() {
        // 지역이름
        self.viewModel.$locationName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                self?.locationLabel.text = "\(location)"
                
            }
            .store(in: &cancellables)
        
        // 현재 날씨
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
        
        // 시간별 날씨
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
    
    // Weather 시간별 날씨배열 함수
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
    
    private func setupBindings() {
        viewModel.$model
            .receive(on: DispatchQueue.main)
            .sink { [weak self] model in
                self?.updateUI(with: model)
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(with model: HomeModel) {
        weeklyRecordDataView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        weeklyRecordDataView.addArrangedSubview(createRecordItemView(title: "달린 횟수", value: "\(model.weeklyRecord.runCount)회"))
        weeklyRecordDataView.addArrangedSubview(createRecordItemView(title: "달린 시간", value: model.weeklyRecord.runTime))
        weeklyRecordDataView.addArrangedSubview(createRecordItemView(title: "달린 거리", value: String(format: "%.2f Km", model.weeklyRecord.runDistance)))
        
        letsRideTitleLabel.text = "\(model.userName)님, 라이딩 고고씽?"
    }
}
