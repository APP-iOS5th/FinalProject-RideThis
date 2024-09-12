import UIKit

// 앱 최초 실행하면 보이는 화면
class SplashView: UIViewController {
    
    var coordinator: AppCoordinator?
    private var tapCount = 0
    private let tapThreshold = 8
    
    // 스플래시 이미지를 표시하는 UIImageView
    private lazy var splashImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "logoTransparent"))
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    // 앱 타이틀을 표시하는 UILabel
    private let titleLabel: RideThisLabel = {
        let label = RideThisLabel(fontType: .title, fontColor: .black, text: "RideThis")
        if let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title1).withSymbolicTraits([.traitBold, .traitItalic]) {
            label.font = UIFont(descriptor: descriptor, size: FontCase.title.rawValue)
        }
        return label
    }()
    
    private var shakeTimer: Timer?
    
    // 뷰가 로드될 때 호출되는 메서드
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestureRecognizer()
    }
    
    // 뷰가 나타난 후 호출되는 메서드
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.coordinator?.changeTabBarView()
        }
    }
    
    // UI 요소들을 설정하고 배치하는 메서드
    private func setupUI() {
        view.backgroundColor = .primaryBackgroundColor
        
        view.addSubview(splashImageView)
        view.addSubview(titleLabel)
        
        splashImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(200)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(splashImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
    }
    
    // 제스처 인식기를 설정하는 메서드
    private func setupGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        splashImageView.addGestureRecognizer(tapGesture)
    }
    
    // 탭 제스처를 처리하는 메서드
    @objc private func handleTap() {
        tapCount += 1
        if tapCount == tapThreshold {
            changeLogoImage()
        }
    }
    
    // 로고 이미지와 타이틀을 변경하는 메서드
    private func changeLogoImage() {
        splashImageView.image = UIImage(named: "bokdonge")
        titleLabel.text = "달려라 복동이!"
    }
}
