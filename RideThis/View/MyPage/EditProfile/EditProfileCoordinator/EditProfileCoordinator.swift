import UIKit

class EditProfileCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator]
    
    init(navigationController: UINavigationController, childCoordinators: [any Coordinator]) {
        self.navigationController = navigationController
        self.childCoordinators = childCoordinators
    }
    
    func start() {
        
    }
}
