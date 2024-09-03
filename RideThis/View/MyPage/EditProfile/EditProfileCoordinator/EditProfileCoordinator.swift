import UIKit

class EditProfileCoordinator: Coordinator, ProfileImageUpdateDelegate {
    
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    var user: User
    
    init(navigationController: UINavigationController, user: User) {
        self.navigationController = navigationController
        self.user = user
    }
    
    func start() {
        let editView = EditProfileInfoView(user: self.user, viewModel: EditProfileInfoViewModel())
        editView.editProfileCoordinator = self
        editView.updateImageDelegate = self
        
        navigationController.pushViewController(editView, animated: true)
    }
    
    func imageUpdate(image: UIImage) {
        for controller in navigationController.viewControllers {
            if let myPage = controller as? MyPageView {
                myPage.imageUpdate(image: image)
                break
            }
        }
    }
}
