import UIKit

// 앱 최초 실행하면 보이는 화면
class SplashView: UIViewController {
        
    var coordinator: AppCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 2초 후에 메인 화면으로 전환
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.coordinator?.changeTabBarView()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .primaryBackgroundColor
        
        let splashImageView = UIImageView(image: UIImage(named: "logoTransparent"))
        splashImageView.translatesAutoresizingMaskIntoConstraints = false
        splashImageView.contentMode = .scaleAspectFit
        view.addSubview(splashImageView)
        
        let titleLabel = UILabel()
        titleLabel.text = "RideThis"
        
        // UIFontDescriptor를 사용하여 Bold Italic 폰트를 설정
        if let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title1).withSymbolicTraits([.traitBold, .traitItalic]) {
            titleLabel.font = UIFont(descriptor: descriptor, size: 28)
        } else {
            // 폰트를 찾을 수 없는 경우 기본 폰트로 설정
            titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        }

        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            splashImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            splashImageView.widthAnchor.constraint(equalToConstant: 200),
            splashImageView.heightAnchor.constraint(equalToConstant: 200),
            
            titleLabel.topAnchor.constraint(equalTo: splashImageView.bottomAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

#Preview {
    UINavigationController(rootViewController: SplashView())
}
