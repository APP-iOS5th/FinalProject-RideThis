import UIKit

class FollowManageCoordinator: Coordinator, UpdateUserDelegate {
    
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    var user: User
    
    init(navigationController: UINavigationController, user: User) {
        self.navigationController = navigationController
        self.user = user
    }
    
    func start() {
        let followView = FollowManageView(user: user, followViewModel: FollowManageViewModel())
        followView.followCoordinator = self
        self.navigationController.pushViewController(followView, animated: true)
    }
    
    func updateUser(user: User) {
        UserService.shared.signedUser = user
    }
}
