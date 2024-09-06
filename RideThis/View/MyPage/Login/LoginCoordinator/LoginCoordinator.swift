import Foundation
import UIKit

class LoginCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    var prevViewCase: ViewCase
    
    var backBtnTitle: String
    
    init(navigationController: UINavigationController, prevViewCase: ViewCase, backBtnTitle: String) {
        self.navigationController = navigationController
        self.prevViewCase = prevViewCase
        self.backBtnTitle = backBtnTitle
    }
    
    func start() {
        let loginView = LoginView()
        loginView.loginCoordinator = self
        
        self.navigationController.topViewController?.navigationItem.backButtonTitle = backBtnTitle
        
        self.navigationController.pushViewController(loginView, animated: true)
    }
}
