import UIKit

class SearchUserCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let searchUserView = SearchUserView()
        searchUserView.coordinator = self
        self.navigationController.present(searchUserView, animated: true)
    }
}
