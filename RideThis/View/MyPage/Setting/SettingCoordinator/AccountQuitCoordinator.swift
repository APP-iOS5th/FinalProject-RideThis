import UIKit

class AccountQuitCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let quitView = AccountQuitView()
        quitView.quitCoordinator = self
        
        self.navigationController.pushViewController(quitView, animated: true)
    }
}
