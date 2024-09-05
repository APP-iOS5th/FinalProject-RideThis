import Foundation
import UIKit

class UserProfileCoordinator: Coordinator {
    var navigationController: UINavigationController
    var selectedUser: User
    var childCoordinators: [any Coordinator] = []
    
    init(navigationController: UINavigationController, selectedUser: User) {
        self.navigationController = navigationController
        self.selectedUser = selectedUser
    }
    
    func start() {
        let userProfileView = UserProfileView(selectedUser: self.selectedUser)
        userProfileView.profileCoordinator = self
        
        navigationController.present(userProfileView, animated: true)
    }
}