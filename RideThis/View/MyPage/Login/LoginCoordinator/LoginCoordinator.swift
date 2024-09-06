import Foundation
import UIKit

class LoginCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    var prevViewCase: ViewCase
    
    init(navigationController: UINavigationController, prevViewCase: ViewCase) {
        self.navigationController = navigationController
        self.prevViewCase = prevViewCase
    }
    
    func start() {
        let loginView = LoginView()
        loginView.loginCoordinator = self
        
        self.navigationController.pushViewController(loginView, animated: true)
    }
}
