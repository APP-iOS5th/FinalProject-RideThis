import UIKit
import SnapKit

class DistanceSelectionViewController: RideThisViewController {
    
    var coordinator: DistanceSelectionCoordinator?
    
    private var viewModel = DistanceSelectionViewModel()
    
    private let titleLabel = RideThisLabel(fontType: .title, fontColor: .black, text: "목표 Km")
    
    private var distanceButtons: [UIButton] = []
    
    private let startBtn: UIButton = {
        let button = UIButton(type: .custom)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor.primaryColor
        config.baseForegroundColor = UIColor.white
        config.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        
        var titleAttr = AttributedString("시작")
        titleAttr.font = .systemFont(ofSize: 24, weight: .bold)
        config.attributedTitle = titleAttr
        
        let imageConfig = UIImage.SymbolConfiguration(weight: .bold)
        let image = UIImage(systemName: "bicycle", withConfiguration: imageConfig)
        config.image = image
        config.imagePlacement = .leading
        config.imagePadding = 5
        
        button.configuration = config
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DeviceManager.shared.isCompetetionUse = true
        
        setupUI()
        makeDistanceButtons()
    }
    
    // MARK: setupUI
    private func setupUI() {
        self.title = "경쟁하기"
        
        setupNavigationBar()
        setupLayout()
        setupAction()
    }
    
    // MARK: NavigationBar
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
    
    // MARK: Layout
    private func setupLayout() {
        let safeArea = self.view.safeAreaLayoutGuide
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(startBtn)
        
        titleLabel.snp.makeConstraints { title in
            title.top.equalTo(safeArea.snp.top).offset(20)
            title.left.equalTo(safeArea.snp.left).offset(20)
        }
        
        startBtn.snp.makeConstraints { start in
            start.bottom.equalTo(safeArea.snp.bottom).offset(-50)
            start.right.equalTo(safeArea.snp.right).offset(-20)
            start.left.equalTo(safeArea.snp.left).offset(20)
        }
        
    }
    
    // MARK: Distance Buttons
    private func makeDistanceButtons() {
        let safeArea = self.view.safeAreaLayoutGuide
        
        var prevButton: UIButton? = nil
        
        for distance in DistanceCase.allCases {
            let button = createButton(for: distance)
            self.view.addSubview(button)
            distanceButtons.append(button)
            
            button.snp.makeConstraints { btn in
                btn.left.equalTo(safeArea.snp.left).offset(20)
                btn.right.equalTo(safeArea.snp.right).offset(-20)
                if let prev = prevButton {
                    btn.top.equalTo(prev.snp.bottom).offset(20)
                } else {
                    btn.top.equalTo(titleLabel.snp.bottom).offset(20)
                }
            }
            
            prevButton = button
        }
    }
    
    // 버튼생성 함수
    private func createButton(for distance: DistanceCase) -> UIButton {
        let button = UIButton(type: .custom)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
        config.baseForegroundColor = UIColor(red: 119/255, green: 119/255, blue: 119/255, alpha: 1)
        config.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        
        var titleAttr = AttributedString("\(distance.rawValue)KM")
        titleAttr.font = .systemFont(ofSize: 24, weight: .bold)
        config.attributedTitle = titleAttr
        
        button.configuration = config
        button.tag = Int(distance.rawValue) ?? 0
        button.addTarget(self, action: #selector(distanceBtnTap(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }
    // 버튼 탭
    @objc private func distanceBtnTap(_ sender: UIButton) {
        for button in distanceButtons {
            if button == sender {
                let distanceValue = "\(button.tag)"
                self.viewModel.chooseDistance(distance: distanceValue)
                
                button.configuration?.baseBackgroundColor = UIColor.primaryColor
                button.configuration?.baseForegroundColor = .white
                
                self.startBtn.isEnabled = true
            } else {
                button.configuration?.baseBackgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
                button.configuration?.baseForegroundColor = UIColor(red: 119/255, green: 119/255, blue: 119/255, alpha: 1)
            }
        }
    }
    
    // MARK: Setup Button Action
    private func setupAction() {
        startBtn.addAction(UIAction { [weak self] _ in
            self?.coordinator?.moveToCountView(with: self?.viewModel.distance ?? "")
        }, for: .touchUpInside)
    }
    
}
