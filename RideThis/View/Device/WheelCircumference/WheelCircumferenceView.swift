import UIKit
import SnapKit
import Combine

class WheelCircumferenceView: UIViewController {
    // MARK: - Properties
    var coordinator: WheelCircumferenceCoordinator?
    
    private let viewModel: DeviceViewModel
    private let wheelSearchLabel = RideThisLabel(fontType: .sectionTitle, fontColor: .black, text: "휠 찾기")
    private let searchTextField = UITextField()
    private let infoLabel = RideThisLabel(fontType: .infoMessage, fontColor: .recordTitleColor, text: "*일반적인 표준 로드 자전거 타이어 크기는 2110(700c X 25)mm이며, 이는 표준 로드 타이어로 직경 약 700mm, 폭 25mm를 나타냅니다.")
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private let headerView = UIView()
    private let millimeterHeaderLabel = UILabel()
    private let tireSizeHeaderLabel = UILabel()
    private let inchHeaderLabel = UILabel()

    var selectedCircumference: (Int, String)?
    var onCircumferenceSelected: ((Int, String) -> Void)?

    private var cancellables = Set<AnyCancellable>()
    
    var currentWheelCircumference: Int?
    
    private var isInitialLayout = true
    
    // MARK: - Initialization
    
    /// WheelCircumferenceView의 새 인스턴스를 초기화합니다.
    /// - Parameters:
    ///   - viewModel: WheelCircumferenceView에서 사용할 DeviceViewModel 인스턴스
    ///   - currentWheelCircumference: 현재 선택된 휠 둘레 값 (밀리미터 단위). nil일 경우 선택된 값이 없음을 의미합니다.
    init(viewModel: DeviceViewModel, currentWheelCircumference: Int?) {
        self.viewModel = viewModel
        self.currentWheelCircumference = currentWheelCircumference
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupTableView()
        setupBindings()
        setupKeyboardDismiss()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if isInitialLayout {
            isInitialLayout = false
            scrollToSelectedRow(animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 검색 텍스트 필드를 비우고 검색 결과 초기화
        searchTextField.text = ""
        viewModel.filterWheelCircumferences(with: "")
        
        // 테이블 뷰 리로드
        tableView.reloadData()
    }

    // MARK: - UI Setup
    
    /// 네비게이션 바를 설정합니다.
    private func setupNavigationBar() {
        title = "휠 둘레"
        navigationItem.backButtonTitle = "Back"
    }

    /// UI 요소들을 설정합니다.
    private func setupUI() {
        view.backgroundColor = .primaryBackgroundColor

        configureSearchTextField()
        configureInfoLabel()
        configureTableView()
        configureHeaderView()
        addSubviews()
        setupConstraints()
    }

    /// 검색 텍스트 필드를 구성합니다.
    private func configureSearchTextField() {
        searchTextField.placeholder = "휠 크기를 검색해주세요.(ex: 1020)"
        searchTextField.borderStyle = .roundedRect
        searchTextField.backgroundColor = .white
        searchTextField.font = UIFont.systemFont(ofSize: FontCase.defaultSize.rawValue)
        searchTextField.keyboardType = .numberPad
    }

    /// 정보 레이블을 구성합니다.
    private func configureInfoLabel() {
        infoLabel.numberOfLines = 0
    }

    /// 헤더 뷰를 구성합니다.
    private func configureHeaderView() {
        headerView.backgroundColor = .primaryBackgroundColor
        headerView.clipsToBounds = true

        [millimeterHeaderLabel, tireSizeHeaderLabel, inchHeaderLabel].forEach {
            $0.font = UIFont.boldSystemFont(ofSize: 14)
            $0.textColor = .black
            headerView.addSubview($0)
        }

        millimeterHeaderLabel.text = "Millimeter"
        tireSizeHeaderLabel.text = "Tire Size"
        inchHeaderLabel.text = "Inch"

        setupHeaderLabelsConstraints()
    }

    /// 헤더 레이블들의 제약 조건을 설정합니다.
    private func setupHeaderLabelsConstraints() {
        millimeterHeaderLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(13)
            make.centerY.equalToSuperview()
            make.width.equalTo(90)
        }

        tireSizeHeaderLabel.snp.makeConstraints { make in
            make.left.equalTo(millimeterHeaderLabel.snp.right).offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(100)
        }

        inchHeaderLabel.snp.makeConstraints { make in
            make.left.equalTo(tireSizeHeaderLabel.snp.right).offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(50)
        }
    }

    /// 테이블 뷰를 구성합니다.
    private func configureTableView() {
        tableView.register(WheelCircumferenceSelectionCell.self, forCellReuseIdentifier: "WheelCircumferenceSelectionCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .primaryBackgroundColor
        tableView.isScrollEnabled = true
        tableView.layer.cornerRadius = 10
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        tableView.clipsToBounds = true
    }

    /// UI 요소들의 제약 조건을 설정합니다.
    private func setupConstraints() {
        wheelSearchLabel.snp.makeConstraints { wheelSearchLabel in
            wheelSearchLabel.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            wheelSearchLabel.left.right.equalToSuperview().inset(20)
        }

        searchTextField.snp.makeConstraints { searchTextField in
            searchTextField.top.equalTo(wheelSearchLabel.snp.bottom).offset(10)
            searchTextField.left.right.equalToSuperview().inset(20)
            searchTextField.height.equalTo(45)
        }

        infoLabel.snp.makeConstraints { infoLabel in
            infoLabel.top.equalTo(searchTextField.snp.bottom).offset(10)
            infoLabel.left.equalTo(searchTextField.snp.left).inset(8)
            infoLabel.right.equalTo(searchTextField.snp.right).inset(5)
        }

        headerView.snp.makeConstraints { headerView in
            headerView.top.equalTo(infoLabel.snp.bottom).offset(10)
            headerView.left.right.equalTo(searchTextField)
            headerView.height.equalTo(44)
        }

        tableView.snp.makeConstraints { tableView in
            tableView.top.equalTo(headerView.snp.bottom)
            tableView.left.right.equalTo(searchTextField)
            tableView.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    /// 서브뷰들을 메인 뷰에 추가합니다.
    private func addSubviews() {
        view.addSubview(wheelSearchLabel)
        view.addSubview(searchTextField)
        view.addSubview(infoLabel)
        view.addSubview(headerView)
        view.addSubview(tableView)
    }

    /// 테이블 뷰의 delegate와 dataSource를 설정합니다.
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    /// ViewModel과 View를 바인딩합니다.
    private func setupBindings() {
        searchTextField.textPublisher
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                self?.viewModel.filterWheelCircumferences(with: searchText)
            }
            .store(in: &cancellables)

        viewModel.$filteredWheelCircumferences
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    /// 키보드 dismiss를 설정합니다.
    private func setupKeyboardDismiss() {
        tableView.keyboardDismissMode = .onDrag
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    /// 키보드를 dismiss합니다.
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /// 주어진 둘레에 해당하는 행을 선택합니다.
    /// - Parameter circumference: 선택할 휠 둘레 값
    private func selectRow(for circumference: Int) {
        if let index = viewModel.filteredWheelCircumferences.firstIndex(where: { $0.millimeter == circumference }) {
            let indexPath = IndexPath(row: index, section: 0)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .middle)
        }
    }
    
    /// 선택된 행으로 스크롤합니다.
    /// - Parameter animated: 애니메이션 여부
    private func scrollToSelectedRow(animated: Bool = true) {
        guard let currentWheelCircumference = currentWheelCircumference,
              let index = viewModel.filteredWheelCircumferences.firstIndex(where: { $0.millimeter == currentWheelCircumference }) else {
            return
        }
        
        let indexPath = IndexPath(row: index, section: 0)
        tableView.scrollToRow(at: indexPath, at: .middle, animated: animated)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension WheelCircumferenceView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredWheelCircumferences.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WheelCircumferenceSelectionCell", for: indexPath) as? WheelCircumferenceSelectionCell else {
            return UITableViewCell()
        }
        
        let wheelCircumference = viewModel.filteredWheelCircumferences[indexPath.row]
        cell.configure(with: wheelCircumference)
        
        // 현재 휠 둘레와 일치하는 경우 선택 상태로 설정
        cell.setSelected(wheelCircumference.millimeter == currentWheelCircumference, animated: false)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let wheelCircumference = viewModel.filteredWheelCircumferences[indexPath.row]
        currentWheelCircumference = wheelCircumference.millimeter
        
        // 선택된 셀을 중앙으로 스크롤
        scrollToSelectedRow()
        
        Task {
            do {
                try await viewModel.updateWheelCircumferenceInFirebase(wheelCircumference.millimeter)
                DispatchQueue.main.async {
                    self.onCircumferenceSelected?(wheelCircumference.millimeter, wheelCircumference.tireSize)
                    tableView.reloadData()
                }
            } catch {
                print("Error updating wheel circumference: \(error)")
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

// MARK: - UITextField Extension
extension UITextField {
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self)
            .map { ($0.object as? UITextField)?.text ?? "" }
            .eraseToAnyPublisher()
    }
}
