import Foundation
import UIKit

class LoginCoordinator: Coordinator, ChangeRecordButtonVisible {
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator]
    var prevViewCase: ViewCase
    
    var backBtnTitle: String
    
    init(navigationController: UINavigationController, childCoordinators: [any Coordinator], prevViewCase: ViewCase, backBtnTitle: String) {
        self.navigationController = navigationController
        self.childCoordinators = childCoordinators
        self.prevViewCase = prevViewCase
        self.backBtnTitle = backBtnTitle
    }
    
    func start() {
        let loginView = LoginView()
        loginView.btnChangeDelegate = self
        loginView.loginCoordinator = self
        childCoordinators.append(self)
        
        self.navigationController.topViewController?.navigationItem.backButtonTitle = backBtnTitle
        
        self.navigationController.pushViewController(loginView, animated: true)
    }
    
    func toPreviousView() {
        navigationController.popViewController(animated: true)
    }
    
    func changeButton(afterLogin: Bool) {
        for ctr in navigationController.viewControllers {
            if let sumUpView = ctr as? RecordSumUpView {
                sumUpView.changeButton(afterLogin: afterLogin)
                break
            }
        }
    }
}
