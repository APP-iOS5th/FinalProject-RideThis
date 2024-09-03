import UIKit

class AccountSettingCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let accountSetting = AccountSettingView()
        accountSetting.coordinator = self
        
        self.navigationController.pushViewController(accountSetting, animated: true)
    }
}
