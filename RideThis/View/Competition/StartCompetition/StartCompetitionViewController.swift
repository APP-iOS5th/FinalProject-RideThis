import UIKit
import SnapKit
import Combine

class StartCompetitionViewController: RideThisViewController {

    var goalDistance: String
    private let viewModel: StartCometitionViewModel
    private var cancellables = Set<AnyCancellable>()

    private let timerRecord = RecordContainer(title: "Timer", recordText: "00:00", view: "record")
    private let cadenceRecord = RecordContainer(title: "Cadence", recordText: "0 RPM", view: "record")
    private let speedRecord = RecordContainer(title: "Speed", recordText: "0 km/h", view: "record")
    private let distanceRecord = RecordContainer(title: "Distance", recordText: "0 km", view: "record")
    private let calorieRecord = RecordContainer(title: "Calories", recordText: "0 kcal", view: "record")

    private let giveUpBtn: UIButton = {
        let button = UIButton(type: .custom)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor.primaryColor
        config.baseForegroundColor = UIColor.white
        config.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20)

        var titleAttr = AttributedString("포기")
        titleAttr.font = .systemFont(ofSize: 17, weight: .semibold)
        config.attributedTitle = titleAttr

        let imageConfig = UIImage.SymbolConfiguration(weight: .semibold)
        let image = UIImage(systemName: "flag.fill", withConfiguration: imageConfig)
        config.image = image
        config.imagePlacement = .leading
        config.imagePadding = 5

        button.configuration = config
        button.layer.cornerRadius = 13
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    private let blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.contentView.backgroundColor = .white
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        return blurView
    }()

    private let bottomLabel = RideThisLabel(fontType: .defaultSize, fontColor: .black, text: "기록 중에는 탭바를 사용하실 수 없습니다.")

    // MARK: 초기화 및 데이터 바인딩
    init(goalDistance: String) {
        self.goalDistance = goalDistance
        let goalDistanceDouble = Double(goalDistance) ?? 0.0
        self.viewModel = StartCometitionViewModel(startTime: Date(), goalDistnace: goalDistanceDouble)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupAction()
    }
    
    // MARK: VeiwIsApeearing
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        tabBarController?.tabBar.items?.forEach{ $0.isEnabled = false }
    }
    
    // MARK: ViewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.items?.forEach{ $0.isEnabled = true }
    }

    // MARK: SetupUI
    private func setupUI() {
        self.title = "\(goalDistance)Km 경쟁하기"
        self.navigationItem.hidesBackButton = true
    
        setupFontUI()
        setupLayout()
        setupBinding()
        setupTimerBinding()
        self.viewModel.startTimer()
    }
    
    // MARK: SetupFontUI
    private func setupFontUI() {
        self.cadenceRecord.titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        self.speedRecord.titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        self.distanceRecord.titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        self.calorieRecord.titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        self.bottomLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
    }

    // MARK: SetupLayout
    private func setupLayout() {
        self.view.addSubview(timerRecord)
        self.view.addSubview(cadenceRecord)
        self.view.addSubview(speedRecord)
        self.view.addSubview(distanceRecord)
        self.view.addSubview(calorieRecord)
        self.view.addSubview(giveUpBtn)
        self.view.addSubview(blurView)
        self.blurView.contentView.addSubview(bottomLabel)

        let safeArea = self.view.safeAreaLayoutGuide

        timerRecord.snp.makeConstraints { timer in
            timer.top.equalToSuperview().offset(80)
            timer.left.equalToSuperview().offset(20)
            timer.right.equalToSuperview().offset(-20)
            timer.height.equalTo(150)
        }
        
        cadenceRecord.snp.makeConstraints { cadence in
            cadence.top.equalTo(timerRecord.snp.bottom).offset(40)
            cadence.left.equalToSuperview().offset(20)
            cadence.width.equalToSuperview().multipliedBy(0.5).offset(-25)
            cadence.height.equalTo(110)
        }
        
        speedRecord.snp.makeConstraints { speed in
            speed.top.equalTo(timerRecord.snp.bottom).offset(40)
            speed.left.equalTo(cadenceRecord.snp.right).offset(10)
            speed.right.equalToSuperview().offset(-20)
            speed.height.equalTo(110)
        }
        
        distanceRecord.snp.makeConstraints { distance in
            distance.top.equalTo(cadenceRecord.snp.bottom).offset(15)
            distance.left.equalToSuperview().offset(20)
            distance.width.equalToSuperview().multipliedBy(0.5).offset(-25)
            distance.height.equalTo(110)
        }
        
        calorieRecord.snp.makeConstraints { calory in
            calory.top.equalTo(speedRecord.snp.bottom).offset(15)
            calory.left.equalTo(distanceRecord.snp.right).offset(10)
            calory.right.equalToSuperview().offset(-20)
            calory.height.equalTo(110)
        }

        giveUpBtn.snp.makeConstraints { btn in
            btn.bottom.equalTo(safeArea.snp.bottom).offset(-50)
            btn.centerX.equalTo(self.view.snp.centerX)
            btn.width.equalTo(210)
        }
        
        blurView.snp.makeConstraints { con in
            con.left.right.bottom.equalToSuperview()
            con.height.equalTo(self.tabBarController!.tabBar.frame.height)
        }
        
        bottomLabel.snp.makeConstraints { label in
            label.centerX.equalTo(self.blurView.snp.centerX)
            label.top.equalTo(self.blurView.snp.top).offset(10)
        }
    }
    
    // MARK: Setup Binding Data
    private func setupBinding() {
        timerRecord.updateRecordText(text: viewModel.timer)
        cadenceRecord.updateRecordText(text: "\(viewModel.cadence.formattedWithThousandsSeparator()) RPM")
        speedRecord.updateRecordText(text: "\(viewModel.speed.formattedWithThousandsSeparator()) Km/h")
        distanceRecord.updateRecordText(text: "\(viewModel.distance.formattedWithThousandsSeparator()) Km")
        calorieRecord.updateRecordText(text: "\(viewModel.calorie.formattedWithThousandsSeparator()) Kcal")
        
        // Combine Data Steaming
        self.viewModel.$isFinished
            .receive(on: DispatchQueue.main)
            .removeDuplicates()  // 추가: 값이 변하지 않으면 반복 호출을 방지
            .sink { [weak self] finish in
                guard finish else { return } // finish가 true일 때만 실행
                // 이미 이동했다면 추가로 이동하지 않도록 처리
                if let navController = self?.navigationController,
                   !(navController.viewControllers.last is SummaryRecordViewController) {
                    let summaryRecordVC = SummaryRecordViewController(timer: self?.viewModel.timer ?? "", cadence: self?.viewModel.cadence ?? 0.0, speed: self?.viewModel.speed ?? 0.0, distance: self?.viewModel.goalDistance ?? 0.0, calorie: self?.viewModel.calorie ?? 0.0)
                    navController.pushViewController(summaryRecordVC, animated: true)
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupTimerBinding() {
        viewModel.timerUpdateCallback = { [weak self] newTime in
            self?.timerRecord.updateRecordText(text: newTime)
        }
    }

    // MARK: setupAction
    private func setupAction() {
        giveUpBtn.addAction(UIAction { [weak self] _ in
            self?.showAlert(alertTitle: "경쟁중지", msg: "현재 경쟁기록 진행중입니다. 포기하시겠습니까?", confirm: "포기") {
                self?.navigationController?.popToRootViewController(animated: true)
            }
        }, for: .touchUpInside)
    }
}


