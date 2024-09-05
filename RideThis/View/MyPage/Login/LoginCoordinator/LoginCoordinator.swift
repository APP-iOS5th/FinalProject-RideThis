import Foundation
import UIKit

class LoginCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let loginView = LoginView()
        loginView.loginCoordinator = self
        
        self.navigationController.pushViewController(loginView, animated: true)
    }
}
