import UIKit

class EditProfileCoordinator: Coordinator, ProfileImageUpdateDelegate {
    
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    var user: User
    weak var editProfileInfoView: EditProfileInfoView?
    
    init(navigationController: UINavigationController, user: User) {
        self.navigationController = navigationController
        self.user = user
    }
    
    func start() {
        // 네비게이션 스택에서 EditProfileInfoView 찾기
        if let existingView = navigationController.viewControllers.first(where: { $0 is EditProfileInfoView }) as? EditProfileInfoView {
            
            navigationController.popToViewController(existingView, animated: true)
            
            existingView.updateUser(user: self.user)
        } else {
            let editView = EditProfileInfoView(user: self.user, viewModel: EditProfileInfoViewModel())
            editView.editProfileCoordinator = self
            editView.updateImageDelegate = self
            
            editProfileInfoView = editView
            navigationController.pushViewController(editView, animated: true)
        }
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
