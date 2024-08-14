import UIKit
import SnapKit

class StartCompetitionViewController: RideThisViewController {

    var goalDistance: String

    let recordContainerView = RecordContainerView()

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
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        tabBarController?.tabBar.items?.forEach{ $0.isEnabled = false }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.items?.forEach{ $0.isEnabled = true }
    }

    // MARK: SetupUI
    private func setupUI() {
        self.title = "\(goalDistance)Km 경쟁하기"

        self.navigationItem.hidesBackButton = true
        self.bottomLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)

        setupLayout()
    }

    // MARK: SetupLayout
    private func setupLayout() {
        self.view.addSubview(recordContainerView)
        self.view.addSubview(giveUpBtn)
        self.view.addSubview(blurView)
        self.blurView.contentView.addSubview(bottomLabel)

        let safeArea = self.view.safeAreaLayoutGuide
        

        recordContainerView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(50)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(400)
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

    // MARK: setupAction
    private func setupAction() {
        giveUpBtn.addAction(UIAction { [weak self] _ in
            self?.showAlert(alertTitle: "경쟁중지", msg: "현재 경쟁기록 진행중입니다. 포기하시겠습니까?", confirm: "포기") {
                self?.navigationController?.popToRootViewController(animated: true)
            }
        }, for: .touchUpInside)
    }
}


