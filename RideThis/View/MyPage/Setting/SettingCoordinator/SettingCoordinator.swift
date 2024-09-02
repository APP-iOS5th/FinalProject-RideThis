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
        
        navigationController.pushViewController(settingView, animated: true)
    }
}
