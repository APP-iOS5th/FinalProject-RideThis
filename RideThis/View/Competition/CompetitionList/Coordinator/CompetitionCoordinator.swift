import UIKit

class CompetitionCoordinator: Coordinator {
    
    var navigationController: UINavigationController
    var tabBarController: UITabBarController
    var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController, tabBarController: UITabBarController) {
        self.navigationController = navigationController
        self.tabBarController = tabBarController
    }
    
    func start() {
        let competitionVC = CompetitionView()
        competitionVC.coordinator = self
        
        navigationController.pushViewController(competitionVC, animated: true)
    }
    
    func moveToDistanceSelectionView() {
       let distanceCoordinator = DistanceSelectionCoordinator(navigationController: navigationController)
        childCoordinators.append(distanceCoordinator)
        
        self.navigationController.topViewController?.navigationItem.backButtonTitle = "경쟁"
        
        distanceCoordinator.start()
    }
    
    func moveToDeviceView() {
        tabBarController.selectedIndex = 3
    }
    
    func moveToLoginView() {
        let loginCoordinator = LoginCoordinator(navigationController: navigationController, childCoordinators: childCoordinators, prevViewCase: .competition, backBtnTitle: "경쟁")
        childCoordinators.append(loginCoordinator)
        
        
        loginCoordinator.start()
    }

}
