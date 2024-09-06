import UIKit

class HomeCoordinator: Coordinator {
    var navigationController: UINavigationController
    var tabBarController: UITabBarController
    var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController, tabBarController: UITabBarController) {
        self.navigationController = navigationController
        self.tabBarController = tabBarController
    }
    
    func start() {
        let homeVC = HomeView(viewModel: HomeViewModel())
        homeVC.coordinator = self
        navigationController.pushViewController(homeVC, animated: false)
    }
    
    func showRecordListView() {
        let recordListCoordinator = RecordListCoordinator(navigationController: self.navigationController)
        
        self.navigationController.topViewController?.navigationItem.backButtonTitle = "Home"
        
        recordListCoordinator.start()
    }
    
    func showRecordView() {
        if let recordNav = tabBarController.viewControllers?[2] as? UINavigationController {
            tabBarController.selectedIndex = 2
            if recordNav.topViewController is RecordView {
                return
            }
            
            let recordCoordinator = RecordCoordinator(navigationController: recordNav, tabBarController: tabBarController)
            childCoordinators.append(recordCoordinator)
            recordCoordinator.start()
        }
    }
    
    func showLoginView() {
        let loginVC = LoginView()
        self.navigationController.topViewController?.navigationItem.backButtonTitle = "Home"
        
        self.navigationController.pushViewController(loginVC, animated: true)
    }
}
