import UIKit

class FollowManageCoordinator: Coordinator, UpdateUserDelegate {
    
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    var user: User
    let followView: FollowManageView
    
    init(navigationController: UINavigationController, user: User) {
        self.navigationController = navigationController
        self.user = user
        self.followView = FollowManageView(user: user, followViewModel: FollowManageViewModel())
    }
    
    func start() {
        followView.followCoordinator = self
        self.navigationController.pushViewController(followView, animated: true)
    }
    
    func updateUser(user: User) {
        followView.updateUser(user: user)
    }
}
