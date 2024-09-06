import UIKit

class SignUpCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator]
    let userId: String
    let userEmail: String?
    
    init(navigationController: UINavigationController, childCoordinators: [any Coordinator], userId: String, userEmail: String?) {
        self.navigationController = navigationController
        self.childCoordinators = childCoordinators
        self.userId = userId
        self.userEmail = userEmail
    }
    
    func start() {
        let signUpView = SignUpInfoView(userId: userId, userEmail: userEmail)
        signUpView.signUpCoordinator = self
        signUpView.modalPresentationStyle = .overFullScreen
        
        navigationController.present(signUpView, animated: true)
    }
}
