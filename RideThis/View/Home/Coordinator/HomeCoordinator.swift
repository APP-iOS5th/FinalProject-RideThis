import UIKit

class HomeCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
    }
    
    func start() {
        let homeVC = HomeView()
        homeVC.coordinator = self

        navigationController.pushViewController(homeVC, animated: true)
    }
}
