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
        distanceCoordinator.start()
    }
    
    func moveToDeviceView() {
        tabBarController.selectedIndex = 3
    }
    
    // 코디네이터 패턴(개발 예정)
    func moveToLoginView() {
        let loginCoordinator = LoginCoordinator(navigationController: navigationController)
        childCoordinators.append(loginCoordinator)
        
        loginCoordinator.start()
    }

}
