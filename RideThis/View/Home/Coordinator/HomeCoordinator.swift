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
        let homeVC = HomeView()
        homeVC.coordinator = self
        navigationController.pushViewController(homeVC, animated: false)
    }
    
    func showRecordListView() {
        tabBarController.selectedIndex = 2 // Assuming RecordView is the third tab
        if let recordNav = tabBarController.viewControllers?[2] as? UINavigationController {
            let recordCoordinator = RecordCoordinator(navigationController: recordNav, tabBarController: tabBarController)
            childCoordinators.append(recordCoordinator)
            recordCoordinator.showRecordListView()
        }
    }
    
    func showRecordView() {
        tabBarController.selectedIndex = 2 // Assuming RecordView is the third tab
        if let recordNav = tabBarController.viewControllers?[2] as? UINavigationController {
            let recordCoordinator = RecordCoordinator(navigationController: recordNav, tabBarController: tabBarController)
            childCoordinators.append(recordCoordinator)
            recordCoordinator.start()
        }
    }
}
