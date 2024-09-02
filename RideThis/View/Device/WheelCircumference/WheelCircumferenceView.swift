import UIKit
import SnapKit
import Combine

class WheelCircumferenceView: UIViewController {
    // MARK: - Properties
    private let viewModel: DeviceViewModel
    private let wheelSearchLabel = RideThisLabel(fontType: .sectionTitle,
                                                 fontColor: .black,
                                                 text: "휠 찾기")
    private let searchTextField = UITextField()
    private let infoLabel = RideThisLabel(fontType: .infoMessage,
                                          fontColor: .recordTitleColor,
                                          text: "*일반적인 표준 로드 자전거 타이어 크기는 2110(700c X 25)mm이며, 이는 표준 로드 타이어로 직경 약 700mm, 폭 25mm를 나타냅니다.")
    private let tableView = UITableView(frame: .zero,
                                        style: .plain)
    
    private let headerView = UIView()
    private let millimeterHeaderLabel = UILabel()
    private let tireSizeHeaderLabel = UILabel()
    private let inchHeaderLabel = UILabel()

    var selectedCircumference: (Int, String)?
    var onCircumferenceSelected: ((Int, String) -> Void)?

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    /// WheelCircumferenceViewController를 주어진 ViewModel로 초기화
    /// - Parameter viewModel: WheelCircumferenceViewController에서 사용할 ViewModel
    init(viewModel: DeviceViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupTableView()
        setupBindings()
        setupKeyboardDismiss()
    }

    // MARK: - Setup NavigationBar
    private func setupNavigationBar() {
        title = "휠 둘레"
        navigationItem.backButtonTitle = "Back"
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .primaryBackgroundColor

        configureSearchTextField()
        configureInfoLabel()
        configureTableView()
        configureHeaderView()
        addSubviews()
        setupConstraints()
    }

    // MARK: - Configure SearchTextField
    private func configureSearchTextField() {
        searchTextField.placeholder = "휠 크기를 검색해주세요.(ex: 1020)"
        searchTextField.borderStyle = .roundedRect
        searchTextField.backgroundColor = .white
        searchTextField.font = UIFont.systemFont(ofSize: FontCase.defaultSize.rawValue)
        searchTextField.keyboardType = .numberPad
    }

    // MARK: - Configure InfoLabel
    private func configureInfoLabel() {
        infoLabel.numberOfLines = 0
    }

    // MARK: - Configure HeaderView
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

        millimeterHeaderLabel.snp.makeConstraints { millimeterHeaderLabel in
            millimeterHeaderLabel.left.equalToSuperview().offset(13)
            millimeterHeaderLabel.centerY.equalToSuperview()
            millimeterHeaderLabel.width.equalTo(90)
        }

        tireSizeHeaderLabel.snp.makeConstraints { tireSizeHeaderLabel in
            tireSizeHeaderLabel.left.equalTo(millimeterHeaderLabel.snp.right).offset(16)
            tireSizeHeaderLabel.centerY.equalToSuperview()
            tireSizeHeaderLabel.width.equalTo(100)
        }

        inchHeaderLabel.snp.makeConstraints { inchHeaderLabel in
            inchHeaderLabel.left.equalTo(tireSizeHeaderLabel.snp.right).offset(16)
            inchHeaderLabel.centerY.equalToSuperview()
            inchHeaderLabel.width.equalTo(50)
        }
    }

    // MARK: - Configure TableView
    private func configureTableView() {
        tableView.register(WheelCircumferenceSelectionCell.self, forCellReuseIdentifier: "WheelCircumferenceSelectionCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .primaryBackgroundColor
        tableView.isScrollEnabled = true
        tableView.layer.cornerRadius = 10
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        tableView.clipsToBounds = true
    }

    // MARK: - Setup Constraints
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

    // MARK: - Add Subviews
    private func addSubviews() {
        view.addSubview(wheelSearchLabel)
        view.addSubview(searchTextField)
        view.addSubview(infoLabel)
        view.addSubview(headerView)
        view.addSubview(tableView)
    }

    // MARK: - Setup TableView
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    // MARK: - Setup Bindings
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
    
    // MARK: - Setup Keyboard Dismiss
    private func setupKeyboardDismiss() {
        tableView.keyboardDismissMode = .onDrag
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension WheelCircumferenceView: UITableViewDelegate, UITableViewDataSource {
    /// numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredWheelCircumferences.count
    }

    /// cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WheelCircumferenceSelectionCell", for: indexPath) as? WheelCircumferenceSelectionCell else {
            return UITableViewCell()
        }
        
        let wheelCircumference = viewModel.filteredWheelCircumferences[indexPath.row]
        cell.configure(with: wheelCircumference)
        
        if let selectedCircumference = selectedCircumference {
            cell.isSelected = selectedCircumference == (wheelCircumference.millimeter, wheelCircumference.tireSize)
        } else {
            cell.isSelected = false
        }
        
        return cell
    }
    
    /// didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let wheelCircumference = viewModel.filteredWheelCircumferences[indexPath.row]
        self.selectedCircumference = (wheelCircumference.millimeter, wheelCircumference.tireSize)
        
        // Firebase 업데이트
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

    /// heightForRowAt
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
