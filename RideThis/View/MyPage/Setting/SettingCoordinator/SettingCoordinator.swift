import UIKit

class SettingCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let settingView = SettingView()
        settingView.settingCoordinator = self
        
        self.navigationController.topViewController?.navigationItem.backButtonTitle = "마이페이지"
        
        navigationController.pushViewController(settingView, animated: true)
    }
    
    func showPrivacyPolicy() { // 개인정보 처리방침 사이트로 이동
        let urlString = "https://radial-scion-728.notion.site/e302599d83064e87bd3281761b541758?pvs=4"
        let privacyPolicyVC = PrivacyPolicyViewController(urlString: urlString)
        let navController = UINavigationController(rootViewController: privacyPolicyVC)
        navigationController.present(navController, animated: true, completion: nil)
    }
}
